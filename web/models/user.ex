defmodule Elmira.User do
  use Elmira.Web, :model

  schema "users" do
    field :name

    timestamps
  end


  def changeset(user, params \\ :empty) do
    user
    |> cast(params, ~w(name), ~w())
    |> validate_length(:name, min: 1)
  end

end
