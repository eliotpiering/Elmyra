import ElixirMedia.ConnCase
import ElixirMedia.Factory


defmodule ElixirMedia.ArtistControllerTest do
  use ElixirMedia.ConnCase

  test "#index renders a list of artists" do
    conn = build_conn()
    artist = insert(:artist)

    conn = get conn, artist_path(conn, :index)

    assert json_response(conn, 200) == render_json(ElixirMedia.ArtistView, "index.json", artists: [artist])
  end

  test "#show renders a single artist" do
    conn = build_conn()
    artist = insert(:artist)

    conn = get conn, artist_path(conn, :show, artist)

    assert json_response(conn, 200) == render_json(ElixirMedia.ArtistView, "show.json", artist: artist)
  end
end
