defmodule FantasyWeb.FallbackControllerTest do
  use FantasyWeb.ConnCase, async: true

  alias FantasyWeb.FallbackController

  setup do
    id = Ecto.UUID.generate()
    {:ok, id: id}
  end

  test "returns 400 with invalid uuid", %{conn: conn} do
    reason = "invalid id format"

    conn = call_controller(conn, {:error, :invalid_uuid, reason})

    assert %{"errors" => %{"detail" => "Bad Request", "reason" => ^reason}} =
             json_response(conn, 400)
  end

  test "returns 400 when {:error, :bad_request} is returned", %{conn: conn} do
    conn = call_controller(conn, {:error, :bad_request})

    assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
  end

  test "returns 500 when {:error, :internal_server_error} is returned", %{conn: conn} do
    conn = call_controller(conn, {:error, :internal_server_error})

    assert %{"errors" => %{"detail" => "Internal Server Error"}} = json_response(conn, 500)
  end

  test "returns 403 when {:error, :forbidden} is returned", %{conn: conn} do
    conn = call_controller(conn, {:error, :forbidden})

    assert %{"errors" => %{"detail" => "Forbidden"}} = json_response(conn, 403)
  end

  test "returns 503 when {:error, :service_unavailable} is returned", %{conn: conn} do
    conn = call_controller(conn, {:error, :service_unavailable})

    assert %{"errors" => %{"detail" => "Service Unavailable"}} = json_response(conn, 503)
  end

  test "returns 404 when {:error, not_found} is returned}", %{conn: conn} do
    conn = call_controller(conn, {:error, :not_found})

    assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
  end

  test "returns 400 when {:error, reason} is returned", %{conn: conn} do
    conn = call_controller(conn, {:error, :referee_not_found})

    assert %{"errors" => %{"detail" => "Bad Request", "reason" => "referee_not_found"}} =
             json_response(conn, 400)
  end

  test "returns 400 when {:error, nil} is returned", %{conn: conn} do
    conn = call_controller(conn, {:error, "some known error"})

    assert %{"errors" => %{"detail" => "Bad Request", "reason" => "some known error"}} =
             json_response(conn, 400)
  end

  defp call_controller(conn, params) do
    conn
    |> Phoenix.Controller.accepts(["json"])
    |> FallbackController.call(params)
  end
end
