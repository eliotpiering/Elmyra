defmodule Elmira.QueueChannel do
  use Phoenix.Channel

  def join("queue:lobby", message, socket) do
    IO.puts("joined queue:lobby -------------")
    IO.inspect(message)
    maybe_create_new_playlist
    {:ok, socket}
  end

  def handle_in("next_song", %{}, socket) do
    broadcast! socket, "next_song", %{}
    change_playlist_current_song("next")
    IO.puts "handle in --------------- next_song"
    {:noreply, socket}
  end

  def handle_in("previous_song", %{}, socket) do
    broadcast! socket, "previous_song", %{}
    change_playlist_current_song("previous")
    IO.puts "handle in --------------- previous_song"
    {:noreply, socket}
  end

  def handle_in("add_songs", %{"songs" => songs}, socket) do
    IO.puts "handle in --------------- add_songs"
    broadcast! socket, "add_songs", %{songs: songs}
    add_songs_to_playlist(songs)
    IO.inspect(songs)
    {:noreply, socket}
  end

  def handle_in("remove_song", %{"body" => index}, socket) do
    IO.puts "handle in --------------- remove song"
    broadcast! socket, "remove_song", %{body: index}
    remove_song_in_playlist(index)
    {:noreply, socket}
  end

  def handle_in("sync", %{}, socket) do
    IO.puts "handle in --------------- sync"
    songs = get_songs_in_playlist
    current_song = get_current_song_in_playlist
    IO.inspect(songs)
    push socket, "sync", %{songs: songs, current_song: current_song }
    {:noreply, socket}
  end

  # private

  defp default_playlist  do
    Elmira.Repo.get_by(Elmira.Playlist, name: "default")
  end


  defp maybe_create_new_playlist do
    playlist = default_playlist
    if is_nil playlist do
      new_playlist = %Elmira.Playlist{name: "default", current_song: 0}
      Elmira.Repo.insert!(new_playlist)
    end
  end

  defp change_playlist_current_song("next") do
    playlist = default_playlist
    changeset = Elmira.Playlist.changeset(playlist, %{current_song: playlist.current_song + 1})
    Elmira.Repo.update(changeset)
  end

  defp change_playlist_current_song("previous") do
    playlist = default_playlist
    changeset = Elmira.Playlist.changeset(playlist, %{current_song: playlist.current_song - 1})
    Elmira.Repo.update(changeset)
  end

  defp add_songs_to_playlist(songs) do
    default_playlist_id = default_playlist.id

    # TODO how to do this in the right order?
    Enum.map(songs, fn(s) ->
      Elmira.Repo.transaction fn() ->
        import Ecto.Query
        total_count =  Elmira.Repo.one(from i in Elmira.PlaylistItem, select: count("*"))
        IO.inspect(total_count)
        changeset = Elmira.PlaylistItem.changeset(%Elmira.PlaylistItem{}, %{song_id: s["id"], playlist_id: default_playlist_id, order: total_count})
        Elmira.Repo.insert! changeset
      end
    end)
  end

  defp remove_song_in_playlist(index) do
    default_playlist_id = default_playlist.id

    delete = "DELETE from playlist_items
    where `order` = #{index}"

    update = "UPDATE playlist_items set
      `order` = `order` - 1
      where `order` > #{index};"


    Ecto.Adapters.SQL.query!(Elmira.Repo, delete, [])
    Ecto.Adapters.SQL.query!(Elmira.Repo, update, [])
  end

  def get_songs_in_playlist() do
    qry = "SELECT s.*, artists.title as 'artist', albums.title as 'album' FROM playlist_items i
    LEFT JOIN songs s on i.song_id = s.id
    LEFT JOIN albums on s.album_id = albums.id
    LEFT JOIN artists on s.artist_id = artists.id
    LEFT JOIN playlists p on i.playlist_id = p.id
    WHERE p.name = 'default'
    ORDER BY i.order;"

    res = Ecto.Adapters.SQL.query!(Elmira.Repo, qry, [])
    cols = Enum.map res.columns, &(String.to_atom(&1))
    data = Enum.map res.rows, fn(row) ->
      Enum.zip(cols, row)
    end
    Enum.map data, fn(s) ->
      %{
        id: s[:id],
        title: s[:title],
        path: s[:path],
        track: s[:track],
        artist: s[:artist],
        album: s[:album],
      }
    end

  end

  defp get_current_song_in_playlist do
    playlist = default_playlist
    playlist.current_song
  end

end
