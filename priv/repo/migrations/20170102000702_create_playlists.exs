defmodule Elmira.Repo.Migrations.CreatePlaylists do
  use Ecto.Migration

  def change do
    create table(:playlists) do
      add :name, :string
      add :current_song, :integer

      timestamps
    end

  end
end
