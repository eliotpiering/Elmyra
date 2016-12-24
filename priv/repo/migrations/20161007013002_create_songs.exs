defmodule Elmira.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :path, :string
      add :title, :string
      add :year, :integer
      add :track, :integer
      add :album_id, :integer
      add :artist_id, :integer

      timestamps
    end
  end
end
