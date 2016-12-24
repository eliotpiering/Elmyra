defmodule ElixirMedia.ArtistController do
  use ElixirMedia.Web, :controller

  alias ElixirMedia.Artist

  def index(conn, _params) do
    query = from a in Artist
    artists = Repo.all query
    render conn, "index.json", artists: artists
  end

  def show(conn, %{"id" => id}) do
    artist = Repo.get!(Artist, id)
    render(conn, "show.json", artist: artist)
  end

  def songs(conn, %{"id" => id}) do
    query = from s in Artist, where: [id: ^id], preload: [songs: [:album, :artist]]
    artist = (Repo.all query) |> List.first
    render(conn, "songs.json", artist: artist)
  end

end
