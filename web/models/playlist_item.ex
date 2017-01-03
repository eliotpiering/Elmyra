defmodule Elmira.PlaylistItem do
  use Elmira.Web, :model

  schema "playlist_items" do
    field :order, :integer

    field :song_id, :integer
    field :playlist_id, :integer

    # has_one :playlist, Elmira.Playlist
    # has_one :song, Elmira.Song

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:song_id, :playlist_id, :order])
  end

end
