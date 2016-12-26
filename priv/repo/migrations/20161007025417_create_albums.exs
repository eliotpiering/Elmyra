defmodule Elmira.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :title, :string

      timestamps
    end
  end
end
