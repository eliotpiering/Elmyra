defmodule Elmira.Uploader do
  use Elmira.Web, :model

  schema "uploader" do
    field :upload
  end


  def changeset(upload, params \\ :empty) do
    upload
    |> cast(params, ~w())
  end

end
