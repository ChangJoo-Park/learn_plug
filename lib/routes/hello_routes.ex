defmodule LearnPlug.HelloRoutes do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello Elixir!")
  end

  get "/:name" do
    send_resp(conn, 200, "Hello #{name}!")
  end
end
