import Elmira.ModelCase
import Elmira.Factory

defmodule Elmira.SongViewTest do
  use Elmira.ModelCase

  alias Elmira.SongView

  test "song_json" do
    song = insert(:song)

    rendered_song = SongView.song_json(song)

    assert rendered_song == %{
      path: song.path,
      title: song.title,
      inserted_at: song.inserted_at,
      updated_at: song.updated_at
    }
  end

  test "index.json" do
    song = insert(:song)

    rendered_songs = SongView.render("index.json", %{songs: [song]})

    assert rendered_songs == %{
      songs: [SongView.song_json(song)]
    }
  end

  test "show.json" do
    song = insert(:song)

    rendered_song = SongView.render("show.json", %{song: song})

    assert rendered_song == %{
      song: SongView.song_json(song)
    }
  end
end
