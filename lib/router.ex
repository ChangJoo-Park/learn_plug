defmodule LearnPlug.Router do
  use Plug.Router
  alias LearnPlug.HelloRoutes

  plug :match
  plug :dispatch


  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  forward "/hello", to: HelloRoutes

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
