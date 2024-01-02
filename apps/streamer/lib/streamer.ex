defmodule Streamer do
  @moduledoc """
  Documentation for `Streamer`.
  """
  # interface to streamer application
  def start_streaming(symbol) do
    Streamer.Binance.start_link(symbol)
  end
end
