defmodule Elmira.UploadController do
  use Elmira.Web, :controller

  # alias Elmira.Upload

  def create(conn, params) do
    IO.inspect(params)
    render(conn, "create.json", %{})
  end

end
