defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug MyAppWeb.Plugs.Authenticate
  end

  scope "/api", MyAppWeb do
    pipe_through :api

    resources "/assets", AssetController, only: [:create, :show, :delete, :index]
    resources "/groups", GroupController, only: [:create, :update]
    get "/groups/:id/assets", GroupController, :get_assets
    post "/assets/search", AssetController, :search
    post "/login", AuthController, :login
  end

  scope "/", MyAppWeb do
    live_dashboard "/dashboard"
  end
end
