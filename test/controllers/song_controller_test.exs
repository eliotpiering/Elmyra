import ElixirMedia.ConnCase
import ElixirMedia.Factory


defmodule ElixirMedia.SongControllerTest do
  use ElixirMedia.ConnCase

  test "#index renders a list of songs" do
    conn = build_conn()
    song = insert(:song)

    conn = get conn, song_path(conn, :index)

    assert json_response(conn, 200) == render_json(ElixirMedia.SongView, "index.json", songs: [song])
  end

  test "#show renders a single song" do
    conn = build_conn()
    song = insert(:song)

    conn = get conn, song_path(conn, :show, song)

    assert json_response(conn, 200) == render_json(ElixirMedia.SongView, "show.json", song: song)
  end
end
