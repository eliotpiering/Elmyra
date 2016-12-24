defmodule Elmira.Artist do
  use Elmira.Web, :model

  schema "artists" do
    field :title
    has_many :albums, Elmira.Album
    has_many :songs, Elmira.Song

    timestamps
  end
end
