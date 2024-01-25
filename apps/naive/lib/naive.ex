defmodule Naive do
  @moduledoc """
  Documentation for `Naive`.
  """

  alias Streamer.Binance.TradeEvent

  def send_event(%TradeEvent{} = event) do
    # send an event to the trader
    GenServer.cast(:trader, event)
  end
end
