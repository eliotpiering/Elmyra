defmodule Elmira.Artist do
  use Elmira.Web, :model

  schema "artists" do
    field :title
    many_to_many :albums, Elmira.Album, join_through: "artists_albums"
    has_many :songs, Elmira.Song

    timestamps
  end
end
