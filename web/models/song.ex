defmodule ElixirMedia.Song do
  use ElixirMedia.Web, :model

  schema "songs" do
    field :path
    field :title
    field :year, :integer
    field :track, :integer
    belongs_to :artist, ElixirMedia.Artist
    belongs_to :album, ElixirMedia.Album

    timestamps
  end


  def changeset(song, params \\ :empty) do
    song
    |> cast(params, ~w(title path), ~w(year track))
    |> validate_length(:title, min: 1)
  end

end
