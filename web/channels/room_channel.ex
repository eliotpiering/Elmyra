defmodule Elmira.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", message, socket) do
    IO.puts("joined room:lobby -------------")
    IO.inspect(message)
    {:ok, socket}
  end

  def handle_in("new:msg", %{"body" => body}, socket) do
    broadcast! socket, "new:msg", %{body: body}
    IO.puts "handle in ---------------"
    IO.inspect(body)
    {:noreply, socket}
  end
end
