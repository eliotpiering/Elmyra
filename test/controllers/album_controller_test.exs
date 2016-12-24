import ElixirMedia.ConnCase
import ElixirMedia.Factory


defmodule ElixirMedia.AlbumControllerTest do
  use ElixirMedia.ConnCase

  test "#index renders a list of albums" do
    conn = build_conn()
    album = insert(:album)

    conn = get conn, album_path(conn, :index)

    assert json_response(conn, 200) == render_json(ElixirMedia.AlbumView, "index.json", albums: [album])
  end

  test "#show renders a single album" do
    conn = build_conn()
    album = insert(:album)

    conn = get conn, album_path(conn, :show, album)

    assert json_response(conn, 200) == render_json(ElixirMedia.AlbumView, "show.json", album: album)
  end
end
