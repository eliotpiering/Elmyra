defmodule Elmira.Repo.Migrations.CreatePlaylistItems do
  use Ecto.Migration

  def change do
    create table(:playlist_items) do
      add :playlist_id, :integer
      add :song_id, :integer
      add :order, :integer

      timestamps
    end
    create unique_index(:playlist_items, [:order])
    create index(:playlist_items, [:song_id, :playlist_id])
  end
end
