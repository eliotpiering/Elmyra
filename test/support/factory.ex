defmodule Elmira.Factory do
  use ExMachina.Ecto, repo: Elmira.Repo

  def song_factory do
    %Elmira.Song{
      path: "/mnt/music/somthing",
      title: "title"
    }
  end

  def artist_factory do
    %Elmira.Artist{
      title: "artist title"
    }
  end

  def album_factory do
    %Elmira.Album{
      title: "album title"
    }
  end

  def playlist_factory do
    %Elmira.Playlist{
      id: 1,
      name: "default"
    }
  end

  def playlist_item_factory do
    %Elmira.PlaylistItem{
      order: 0
    }
  end


end
