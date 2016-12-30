defmodule Elmira.QueueChannel do
  use Phoenix.Channel

  def join("queue:lobby", message, socket) do
    IO.puts("joined queue:lobby -------------")
    IO.inspect(message)
    {:ok, socket}
  end

  def handle_in("next_song", %{}, socket) do
    broadcast! socket, "next_song", %{}
    IO.puts "handle in ---------------"
    {:noreply, socket}
  end
end
