defmodule ElixirMedia.Artist do
  use ElixirMedia.Web, :model

  schema "artists" do
    field :title
    has_many :albums, ElixirMedia.Album
    has_many :songs, ElixirMedia.Song

    timestamps
  end
end
