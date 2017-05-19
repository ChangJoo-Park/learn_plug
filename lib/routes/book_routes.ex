defmodule LearnPlug.BookRoutes do
  use Plug.Router
  alias LearnPlug.Book
  alias LearnPlug.Repo

  plug :match
  plug :dispatch

  get "/" do
    books = Repo.all(Book)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(books))
  end

  get "/:id" do
    book = Repo.get(Book, id)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(book))
  end
end
