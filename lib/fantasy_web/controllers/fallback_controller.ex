defmodule FantasyWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use FantasyWeb, :controller
  alias FantasyWeb.ErrorView

  require Logger

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    Logger.warn("Failure in action",
      details: %{
        action: changeset.action,
        errors: changeset.errors,
        path: conn.request_path,
        params: conn.params
      }
    )

    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :invalid_uuid, reason}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render(:"400", reason: reason)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render(:"400")
  end

  def call(conn, {:error, :internal_server_error}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(ErrorView)
    |> render(:"500")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(ErrorView)
    |> render(:"403")
  end

  def call(conn, {:error, :service_unavailable}) do
    conn
    |> put_status(:service_unavailable)
    |> put_view(ErrorView)
    |> render(:"503")
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render(:"400", reason: reason)
  end
end
