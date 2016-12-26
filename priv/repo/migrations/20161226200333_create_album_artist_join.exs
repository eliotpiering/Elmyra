defmodule Elmira.Repo.Migrations.CreateAlbumArtistJoin do
  use Ecto.Migration


  def change do
    create table(:artists_albums, primary_key: false) do
      add :album_id, references(:albums)
      add :artist_id, references(:artists)
    end
  end
end
