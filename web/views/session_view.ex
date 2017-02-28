defmodule Elmira.SessionView do
  use Elmira.Web, :view

  def render("index.json", %{sessions: sessions}) do
    %{data: render_many(sessions, Elmira.SessionView, "session.json")}
  end

  def render("show.json", %{session: session}) do
    %{data: render_one(session, Elmira.SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{id: session.id}
  end
end
