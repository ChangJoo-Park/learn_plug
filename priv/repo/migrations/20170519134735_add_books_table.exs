defmodule LearnPlug.Repo.Migrations.AddBooksTable do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :author, :string
      add :language, :string
      add :isbn, :string

      timestamps()
    end
  end
end
