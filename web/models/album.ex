defmodule Elmira.Album do
  use Elmira.Web, :model

  schema "albums" do
    field :title
    has_many :artists, Elmira.Artist
    has_many :songs, Elmira.Song

    timestamps
  end
end
