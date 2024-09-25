defmodule MittyBot.Application do

  use Application
  @impl true

  def start(_type, _args) do
    children = [
      MittyBot
    ]

    opts = [strategy: :one_for_one, name: MittyBot.Supervisor]
    Supervisor.start_link(children, opts)

  end
end
