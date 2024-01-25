defmodule Streamer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Streamer.Worker.start_link(arg)
      # {Streamer.Worker, arg}
      {
        Phoenix.PubSub,
        # the adapter name will instruct PubSub to use pg adapter which will give us distributed process groups
        name: Streamer.PubSub, adapter_name: Phoenix.PubSub.PG2
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Streamer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
