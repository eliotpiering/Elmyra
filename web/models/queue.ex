defmodule Elmira.Queue do
  use GenServer

  # Client API

  # # def start_link do
  # #   IO.inspect(__MODULE__)
  # #   GenServer.start_link(__MODULE__, [], name: :queue)
  # # end

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
    #TODO update current song
    new_queue = Map.update!(queue, :songs, &(List.delete_at(&1, index)))
    {:reply, new_queue, new_queue}
  end

  def handle_call(:next, _from, queue) do
    new_queue = Map.update!(queue, :current_song, &(&1 + 1))
    {:reply, new_queue, new_queue }
  end

  def handle_call(:previous, _from, queue) do
    new_queue = Map.update!(queue, :current_song, &(&1 - 1))
    {:reply, new_queue, new_queue }
  end

  def handle_call({:swap, from, to}, list) do
    # list_ = List.pop_at(index, list)
    {:reply, list }
  end
end
