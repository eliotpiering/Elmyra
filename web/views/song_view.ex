defmodule Elmira.SongView do
  use Elmira.Web, :view

  def render("index.json", %{songs: songs}) do
    %{
      songs: songs_json(songs)
    }
  end

  def render("show.json", %{song: song}) do
    %{
      song: song_json(song)
    }
  end

  def songs_json(songs) do
    Enum.map(songs, &song_json/1)
  end

  def song_json(song) do
    %{
      id: song.id,
      path: song.path,
      title: song.title,
      album: song.album.title,
      artist: song.artist.title,
      track: song.track
    }
  end
end

