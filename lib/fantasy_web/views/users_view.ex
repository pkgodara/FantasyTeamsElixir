defmodule FantasyWeb.UsersView do
  use FantasyWeb, :view

  def render("show.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("login.json", %{user: user, token: token}) do
    %{
      id: user.id,
      email: user.email,
      token: token
    }
  end
end
