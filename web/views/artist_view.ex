defmodule ElixirMedia.ArtistView do
  use ElixirMedia.Web, :view

  def render("index.json", %{artists: artists}) do
    %{
      artists: Enum.map(artists, &artist_json/1)
    }
  end

  def render("show.json", %{artist: artist}) do
    %{
      artist: artist_json(artist)
    }
  end

  def render("songs.json", %{artist: artist}) do
    %{
      songs: ElixirMedia.SongView.songs_json(artist.songs),
    }
  end

  def artist_json(artist) do
    %{
      id: artist.id,
      kind: "artists",
      title: artist.title,
      songs: []
    }
  end
end

