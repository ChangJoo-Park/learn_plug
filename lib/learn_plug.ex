defmodule LearnPlug do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, LearnPlug.Router, [], port: 4000)
    ]

    Logger.info "Started application http://localhost:4000"

    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
