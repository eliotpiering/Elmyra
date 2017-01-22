defmodule Elmira.Router do
  use Elmira.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Elmira do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Elmira do
    pipe_through :api

    resources "/songs", SongController, only: [:index, :show]

    resources "/stream", StreamController, only: [:show]
    resources "/upload", UploadController, only: [:create]

    resources "/albums", AlbumController, only: [:index, :show]
    get "/albums/:id/songs", AlbumController, :songs

    resources "/artists", ArtistController, only: [:index, :show]
    get "/artists/:id/songs", ArtistController, :songs
  end
end
