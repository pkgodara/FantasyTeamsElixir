defmodule FantasyWeb.Router do
  use FantasyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :guardian do
    plug FantasyWeb.Authentication.Pipeline
  end

  scope "/", FantasyWeb do
    pipe_through :api

    post "/signup", UsersController, :signup
    post "/login", UsersController, :login
  end

  scope "/api", FantasyWeb do
    pipe_through [:api, :guardian]

    get "/list-team-players", TeamsController, :list_team_players
    put "/teams/:team_id", TeamsController, :update

    put "/players/:player_id", PlayersController, :update
    post "/players/:player_id/buy", PlayersController, :buy

    get "/transfer-list", TransferListController, :list
    post "/transfers/auction", TransferListController, :auction
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: FantasyWeb.Telemetry
    end
  end
end
