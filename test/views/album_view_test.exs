import Elmira.ModelCase
import Elmira.Factory

defmodule Elmira.AlbumViewTest do
  use Elmira.ModelCase

  alias Elmira.AlbumView

  test "album_json" do
    album = insert(:album)

    rendered_album = AlbumView.album_json(album)

    assert rendered_album == %{
      title: album.title,
      inserted_at: album.inserted_at,
      updated_at: album.updated_at
    }
  end

  test "index.json" do
    album = insert(:album)

    rendered_albums = AlbumView.render("index.json", %{albums: [album]})

    assert rendered_albums == %{
      albums: [AlbumView.album_json(album)]
    }
  end

  test "show.json" do
    album = insert(:album)

    rendered_album = AlbumView.render("show.json", %{album: album})

    assert rendered_album == %{
      album: AlbumView.album_json(album)
    }
  end
end
