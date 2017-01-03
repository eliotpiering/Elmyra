defmodule Elmira.PlaylistController do
  use Elmira.Web, :controller

  alias Elmira.Playlist
  alias Elmira.PlaylistItem

  def index(conn, _params) do
    #TODO figure out preloading and just getting the artist album name b/c thats all we need
    query = from p in Playlist, preload: [:playlist_items]
    songs = Repo.all query
    render conn, "index.json", songs: songs
  end

  def show(conn, %{"id" => id}) do
    query = from s in Song, where: [id: ^id], preload: [:album, :artist]
    song = (Repo.all query) |> List.first
    render(conn, "show.json", song: song)
  end

end
