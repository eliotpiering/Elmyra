import Elmira.ConnCase
import Elmira.Factory


defmodule Elmira.ArtistControllerTest do
  use Elmira.ConnCase

  test "#index renders a list of artists" do
    conn = build_conn()
    artist = insert(:artist)

    conn = get conn, artist_path(conn, :index)

    assert json_response(conn, 200) == render_json(Elmira.ArtistView, "index.json", artists: [artist])
  end

  test "#show renders a single artist" do
    conn = build_conn()
    artist = insert(:artist)

    conn = get conn, artist_path(conn, :show, artist)

    assert json_response(conn, 200) == render_json(Elmira.ArtistView, "show.json", artist: artist)
  end
end
