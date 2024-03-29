defmodule Naive.State do
  # the trader needs to know:
  #   Symbol to trade. (“symbol” here is a pair of assets for example “XRPUSDT”, which is XRP to/from USDT)
  #   placed buy order
  #   placed sell order
  #   profit interval(% to be achieved when buying and selling an asset)
  #   tick_size: used to calculate a valid price. Its the smallest acceptable price movement up or down.  For example in the physical world tick size for USD is a single cent, you can’t sell something for $1.234, it’s either $1.23 or $1.24

  @enforce_keys [:symbol, :profit_interval, :tick_size]
  defstruct [
    :symbol,
    :buy_order,
    :sell_order,
    :profit_interval,
    :tick_size
  ]
end
