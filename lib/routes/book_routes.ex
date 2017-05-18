defmodule LearnPlug.BookRoutes do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, "Book")
  end

  get "/:id" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{
      :name => "The Interpretation of Dreams",
      :author => "Sigmund Freud",
      :publishedAt => "1900"
    }))
  end
end
