defmodule LearnPlug.Book do
  use Ecto.Schema

  schema "books" do
    field :name, :string
    field :author, :string
    field :language, :string
    field :isbn, :string

    timestamps()
  end
end
