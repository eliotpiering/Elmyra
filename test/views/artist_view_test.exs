import Elmira.ModelCase
import Elmira.Factory

defmodule Elmira.ArtistViewTest do
  use Elmira.ModelCase

  alias Elmira.ArtistView

  test "artist_json" do
    artist = insert(:artist)

    rendered_artist = ArtistView.artist_json(artist)

    assert rendered_artist == %{
      title: artist.title,
      inserted_at: artist.inserted_at,
      updated_at: artist.updated_at
    }
  end

  test "index.json" do
    artist = insert(:artist)

    rendered_artists = ArtistView.render("index.json", %{artists: [artist]})

    assert rendered_artists == %{
      artists: [ArtistView.artist_json(artist)]
    }
  end

  test "show.json" do
    artist = insert(:artist)

    rendered_artist = ArtistView.render("show.json", %{artist: artist})

    assert rendered_artist == %{
      artist: ArtistView.artist_json(artist)
    }
  end
end
