defmodule LearnPlug do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, LearnPlug.Router, [], port: 4000),
      supervisor(LearnPlug.Repo, [])
    ]

    Logger.info "Started application http://localhost:4000"

    opts = [strategy: :one_for_one, name: LearnPlug.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
