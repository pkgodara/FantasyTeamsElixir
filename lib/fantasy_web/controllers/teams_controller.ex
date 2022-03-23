defmodule FantasyWeb.TeamsController do
  @moduledoc tags: ["Teams"]

  use FantasyWeb, :controller

  alias Fantasy.Teams
  alias Fantasy.Users.User
  alias FantasyWeb.Authentication

  def list(conn, _) do
    with %User{} = user <- Authentication.get_current_account(conn),
         {:ok, result} <- Teams.list_team_players(user.id) do
      render(conn, "show.json", %{team_players: result})
    end
  end

  def update(conn, %{"team_id" => team_id} = params) do
    with %User{} = user <- Authentication.get_current_account(conn),
         {:ok, team} <- Teams.get_team(team_id),
         {:ok, true} <- Teams.verify_owner(team, user.id),
         {:ok, updated_team} <- Teams.update_team(team, params) do
      render(conn, "show.json", %{team: updated_team})
    end
  end
end
