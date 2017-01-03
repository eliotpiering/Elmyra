defmodule Elmira.Playlist do
  use Elmira.Web, :model

  schema "playlists" do
    field :name, :string
    field :current_song, :integer
    has_many :playlist_items, Elmira.PlaylistItem

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:current_song])
  end

end
