defmodule FantasyWeb.Authentication.ErrorHandler do
  @moduledoc """
  Auth error handler
  """
  use FantasyWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> json(%{error: "Authentication error."})
    |> halt()
  end
end
