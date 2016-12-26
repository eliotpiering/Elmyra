defmodule Elmira.Album do
  use Elmira.Web, :model

  schema "albums" do
    field :title
    many_to_many :artists, Elmira.Artist, join_through: "artists_albums"
    has_many :songs, Elmira.Song

    timestamps
  end
end
