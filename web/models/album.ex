defmodule ElixirMedia.Album do
  use ElixirMedia.Web, :model

  schema "albums" do
    field :title
    has_many :artists, ElixirMedia.Artist
    has_many :songs, ElixirMedia.Song

    timestamps
  end
end
