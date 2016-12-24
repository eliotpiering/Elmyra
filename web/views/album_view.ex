defmodule ElixirMedia.AlbumView do
  use ElixirMedia.Web, :view

  def render("index.json", %{albums: albums}) do
    %{
      albums: Enum.map(albums, &album_json/1)
    }
  end

  def render("show.json", %{album: album}) do
    %{
      album: album_json(album)
    }
  end

  def render("songs.json", %{album: album}) do
    %{
      songs: ElixirMedia.SongView.songs_json(album.songs),
    }
  end

  def album_json(album) do
    %{
      id: album.id,
      kind: "albums",
      title: album.title,
      songs: []
    }
  end
end

