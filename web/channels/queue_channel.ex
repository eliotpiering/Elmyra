defmodule Elmira.QueueChannel do
  use Phoenix.Channel

  def join("queue:lobby", message, socket) do
    IO.puts("joined queue:lobby -------------")
    IO.inspect(message)
    {:ok, socket}
  end

  def handle_in("next_song", %{}, socket) do
    broadcast! socket, "next_song", %{}
    IO.puts "handle in --------------- next_song"
    {:noreply, socket}
  end

  def handle_in("previous_song", %{}, socket) do
    broadcast! socket, "previous_song", %{}
    IO.puts "handle in --------------- previous_song"
    {:noreply, socket}
  end

  def handle_in("add_songs", %{"songs" => songs}, socket) do
    IO.puts "handle in --------------- add_songs"
    broadcast! socket, "add_songs", %{songs: songs}
    IO.inspect(songs)
    {:noreply, socket}
  end



end
