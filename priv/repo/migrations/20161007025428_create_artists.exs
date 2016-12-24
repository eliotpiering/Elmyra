defmodule Elmira.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :title, :string

      timestamps
    end

  end
end
