defmodule ElixirMedia.AlbumController do
  use ElixirMedia.Web, :controller

  alias ElixirMedia.Album

  def index(conn, _params) do
    query = from a in Album
    albums = Repo.all query
    render conn, "index.json", albums: albums
  end

  def show(conn, %{"id" => id}) do
    album = Repo.get!(Album, id)
    render(conn, "show.json", album: album)
  end

  def songs(conn, %{"id" => id}) do
    query = from a in Album, where: [id: ^id], preload: [songs: [:album, :artist]]
    album = (Repo.all query) |> List.first
    render(conn, "songs.json", album: album)
  end

end
