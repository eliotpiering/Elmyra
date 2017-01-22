defmodule Elmira.PageController do
  use Elmira.Web, :controller
  alias Elmira.Uploader

  def index(conn, _params) do
    uploader = Uploader.changeset(%Uploader{})
    render conn, "index.html", uploader: uploader
  end
end
