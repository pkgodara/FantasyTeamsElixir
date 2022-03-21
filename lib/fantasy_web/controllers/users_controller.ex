defmodule FantasyWeb.UsersController do
  @moduledoc tags: ["Users"]

  use FantasyWeb, :controller

  alias Fantasy.Users
  alias FantasyWeb.Authentication

  def signup(conn, %{"email" => email, "password" => passwd}) do
    with {:ok, _result} <- Users.signup(%{email: email, password: passwd}),
         {:ok, user} <- Users.get_user_by_email(email) do
      render(conn, "show.json", %{user: user})
    end
  end

  def login(conn, %{"email" => email, "password" => passwd}) do
    with {:ok, user} <- Users.get_user_by_email(email),
         {:ok, _verified} <- Users.verify_password(user, passwd) do
      conn = Authentication.log_in(conn, user)
      token = Guardian.Plug.current_token(conn)
      render(conn, "login.json", %{user: user, token: token})
    end
  end
end
