defmodule LearnPlug.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/hello" do
    send_resp(conn, 200, "Hello Elixir!")
  end

  get "/hello/:name" do
    send_resp(conn, 200, "Hello #{name}!")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
