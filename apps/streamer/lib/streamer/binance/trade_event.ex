defmodule Streamer.Binance.TradeEvent do
  defstruct [
    :event_type,
    :event_time,
    :symbol,
    :trade_id,
    :price,
    :quantity,
    :buyer_order_id,
    :seller_order_id,
    :trade_time,
    :buyer_market_maker
  ]

  # {
  #   "e": "trade",     // Event type
  #   "E": 123456789,   // Event time
  #   "s": "BNBUSDT",   // Symbol
  #   "t": 12345,       // Trade ID
  #   "p": "0.001",     // Price
  #   "q": "100",       // Quantity
  #   "b": 88,          // Buyer order ID
  #   "a": 50,          // Seller order ID
  #   "T": 123456785,   // Trade time
  #   "m": true,        // Is the buyer the market maker?
  #   "M": true         // Ignore
  # }
end
