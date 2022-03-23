defmodule FantasyWeb.UsersControllerTest do
  use FantasyWeb.ConnCase, async: true

  describe "signup/2" do
    test "successfully signup customer", %{conn: conn} do
      email = "first-last@gmail.com"
      passwd = "password1234"

      params = %{"email" => email, "password" => passwd}

      conn =
        conn
        |> post(Routes.users_path(conn, :signup), params)

      assert %{"email" => ^email} = json_response(conn, 200)
    end

    test "error when signup from invalid email", %{conn: conn} do
      email = "invalid-gmail.com"
      passwd = "password1234"

      params = %{"email" => email, "password" => passwd}

      conn =
        conn
        |> post(Routes.users_path(conn, :signup), params)

      assert %{"errors" => %{"email" => ["invalid email"]}} = json_response(conn, 422)
    end
  end

  describe "login/2" do
    test "successfully get login token", %{conn: conn} do
      email = "first-last@gmail.com"
      passwd = "password1234"
      params = %{"email" => email, "password" => passwd}

      conn1 = conn
      conn2 = conn
      conn3 = conn

      conn1 = post(conn1, Routes.users_path(conn1, :signup), params)
      assert %{"id" => id, "email" => ^email} = json_response(conn1, 200)

      conn2 = post(conn2, Routes.users_path(conn2, :login), params)
      assert %{"id" => ^id, "email" => ^email, "token" => token} = json_response(conn2, 200)

      conn3 =
        conn3
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(Routes.teams_path(conn3, :list))

      assert %{"owner" => ^id} = json_response(conn3, 200)
    end
  end
end
