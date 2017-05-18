defmodule LearnPlug.Router do
  use Plug.Router

  plug :match
  plug :dispatch


  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  forward "/hello", to: LearnPlug.HelloRoutes
  forward "/books", to: LearnPlug.BookRoutes
  
  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
