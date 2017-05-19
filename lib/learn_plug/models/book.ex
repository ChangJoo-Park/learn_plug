defmodule LearnPlug.Book do
  use Ecto.Schema

  @derive { Poison.Encoder, except: [:__meta__] }
  schema "books" do
    field :name, :string
    field :author, :string
    field :language, :string
    field :isbn, :string

    timestamps()
  end
end
