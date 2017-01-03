import Elmira.Factory

defmodule Elmira.QueueChannelTest do
  use Elmira.ChannelCase
  alias Elmira.QueueChannel

  test "get_songs_in_playlist returns songs" do
    playlist = insert(:playlist)
    song = insert(:song)
    playlist_item = insert(:playlist_item, %{playlist_id: playlist.id, song_id: song.id} )

    assert QueueChannel.get_songs_in_playlist
  end
end
