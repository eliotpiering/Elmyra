defmodule Elmira.Queue do
  use GenServer

  # Client API

  def start_link (name) do
    GenServer.start_link(__MODULE__, :ok, name: name )
  end

  # def read do
  #   GenServer.call(:queue, :read)
  # end

  # def add(pid, items) do
  #   GenServer.call(pid, {:add, items})
  # end

  # Server Callbacks

  def init(:ok) do
    {:ok, %{songs: [], current_song: 0}}
  end

  def handle_call(:read, _from, queue) do
    {:reply, queue, queue}
  end

  def handle_call({:add, songs}, _from, queue) do
    new_queue = Map.update!(queue, :songs, &(&1 ++ songs) )
    {:reply, new_queue, new_queue}
  end

  def handle_call({:remove, index}, _from, queue) do
    new_queue =
      queue
      |> Map.update!(:songs, &(List.delete_at(&1, index)))
      |> Map.update!(:current_song, fn current ->
        if current > index do
          current - 1
        else
          current
        end
    end)
    {:reply, new_queue, new_queue}
  end

  def handle_call(:next, _from, queue) do
    new_queue = Map.update!(queue, :current_song, &(&1 + 1))
    {:reply, new_queue, new_queue }
  end

  def handle_call({:change_current_song, current_song }, _from, queue) do
    new_queue = Map.put(queue, :current_song, current_song)
    {:reply, new_queue, new_queue }
  end

  def handle_call(:previous, _from, queue) do
    new_queue = Map.update!(queue, :current_song, &(&1 - 1))
    {:reply, new_queue, new_queue }
  end

  def handle_call({:swap, from, to}, _from, queue) do
    old_songs = queue[:songs]
    a = Enum.at(old_songs, from, :none)
    b = Enum.at(old_songs, to, :none)
    new_songs =
      old_songs
      |> List.replace_at(from, b)
      |> List.replace_at(to, a)

    old_current_song = queue[:current_song]
    new_current_song =
    cond do
      from == old_current_song ->
        to
      to == old_current_song ->
        from
      true ->
        old_current_song
    end

    new_queue =
      queue
        |> Map.put(:current_song, new_current_song)
        |> Map.put(:songs, new_songs)
    {:reply, new_queue, new_queue }
  end
end
