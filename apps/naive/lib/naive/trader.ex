defmodule Naive.Trader do
  # trader abstraction

  use GenServer
  require Logger

  alias Decimal, as: D
  alias Naive.State
  alias Streamer.Binance.TradeEvent

  def start_link(%{} = args) do
    GenServer.start_link(__MODULE__, args, name: :trader)
  end

  def init(%{symbol: symbol, profit_interval: profit_interval}) do
    # Binance rest api only accepts upper cased symbols
    symbol = String.upcase(symbol)

    Logger.info("Initializing new trader for #{symbol}")

    tick_size = fetch_tick_size(symbol)

    {:ok,
     %State{
       symbol: symbol,
       profit_interval: profit_interval,
       tick_size: tick_size
     }}
  end

  defp fetch_tick_size(symbol) do
    Binance.get_exchange_info()
    |> elem(1)
    |> Map.get(:symbols)
    |> Enum.find(&(&1["symbol"] == symbol))
    |> Map.get("filters")
    |> Enum.find(&(&1["filterType"] == "PRICE_FILTER"))
    |> Map.get("tickSize")
  end

  # dealing with a "new" trader, this pattern match on buy order of nil
  def handle_cast(%TradeEvent{price: price}, %State{symbol: symbol, buy_order: nil} = state) do
    # hardcoded
    quantity = "100"

    Logger.info("Placing BUY order for #{symbol} @ #{price}, quantity: #{quantity}")

    {:ok, %Binance.OrderResponse{} = order} =
      Binance.order_limit_buy(symbol, quantity, price, "GTC")

    {:noreply, %{state | buy_order: order}}
  end

  # monitor for an event that matches our by order id and quantity to confirm that our buy order got filled
  def handle_cast(
        %TradeEvent{
          buyer_order_id: order_id,
          quantity: quantity
        },
        %State{
          symbol: symbol,
          buy_order: %Binance.OrderResponse{
            price: buy_price,
            order_id: order_id,
            orig_qty: quantity
          },
          profit_interval: profit_interval,
          tick_size: tick_size
        } = state
      ) do
    sell_price = calculate_sell_price(buy_price, profit_interval, tick_size)

    Logger.info(
      "Buy order filled, placing SELL order for" <>
        "#{symbol} @ #{sell_price}, quantity: #{quantity}"
    )

    # proceed to sell
    {:ok, %Binance.OrderResponse{} = order} =
      Binance.order_limit_sell(symbol, quantity, sell_price, "GTC")

    {:noreply, %{state | sell_order: order}}
  end

  defp calculate_sell_price(buy_price, profit_interval, tick_size) do
    fee = "1.001"

    original_price = D.mult(buy_price, fee)

    net_target_price = D.mult(original_price, D.add("1.0", profit_interval))

    gross_target_price = D.mult(net_target_price, fee)

    D.to_string(D.mult(D.div_int(gross_target_price, tick_size), tick_size), :normal)
  end

  # a trader want to confirm that his sell order was filled
  # otherwise, there is nothing else to do for the trader
  def handle_cast(
        %TradeEvent{seller_order_id: order_id, quantity: quantity},
        %State{sell_order: %Binance.OrderResponse{order_id: order_id, orig_qty: quantity}} = state
      ) do
    Logger.info("Trade finished trader will now exit")

    # :stop will cause the trader process to terminate
    {:stop, :normal, state}
  end

  # fallback
  def handle_cast(%TradeEvent{}, state) do
    {:noreply, state}
  end
end
