import Elmira.ConnCase
import Elmira.Factory


defmodule Elmira.AlbumControllerTest do
  use Elmira.ConnCase

  test "#index renders a list of albums" do
    conn = build_conn()
    album = insert(:album)

    conn = get conn, album_path(conn, :index)

    assert json_response(conn, 200) == render_json(Elmira.AlbumView, "index.json", albums: [album])
  end

  test "#show renders a single album" do
    conn = build_conn()
    album = insert(:album)

    conn = get conn, album_path(conn, :show, album)

    assert json_response(conn, 200) == render_json(Elmira.AlbumView, "show.json", album: album)
  end
end
