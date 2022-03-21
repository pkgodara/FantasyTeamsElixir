defmodule FantasyWeb.Authentication.Pipeline do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :fantasy,
    error_handler: FantasyWeb.Authentication.ErrorHandler,
    module: FantasyWeb.Authentication

  # plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
