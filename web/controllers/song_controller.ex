defmodule ElixirMedia.SongController do
  use ElixirMedia.Web, :controller

  alias ElixirMedia.Song

  def index(conn, _params) do
    #TODO figure out preloading and just getting the artist album name b/c thats all we need
    query = from s in Song, preload: [:album, :artist], limit: 1000
    songs = Repo.all query
    render conn, "index.json", songs: songs
  end

  def show(conn, %{"id" => id}) do
    query = from s in Song, where: [id: ^id], preload: [:album, :artist]
    song = (Repo.all query) |> List.first
    render(conn, "show.json", song: song)
  end

end
