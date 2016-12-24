defmodule Elmira.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :title, :string
      add :artist_id, :integer

      timestamps
    end
  end
end
