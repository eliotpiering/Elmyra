defmodule Elmira.Repo.Migrations.CreatePlaylistItems do
  use Ecto.Migration

  def change do
    create table(:playlist_items) do
      add :playlist_id, :integer
      add :song_id, :integer
      add :order, :integer

      timestamps
    end
    #This should probably be a unique index for order but it broke the swap_songs function
    create index(:playlist_items, [:order])
    create index(:playlist_items, [:song_id, :playlist_id])
  end
end
