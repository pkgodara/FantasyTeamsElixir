defmodule FantasyWeb.PlayersController do
  @moduledoc tags: ["Players"]

  use FantasyWeb, :controller

  alias Fantasy.Teams
  alias Fantasy.Players
  alias Fantasy.Users.User
  alias FantasyWeb.Authentication

  def update(conn, %{"player_id" => player_id} = params) do
    with %User{} = user <- Authentication.get_current_account(conn),
         {:ok, player} <- Players.get_player(player_id),
         {:ok, team} <- Teams.get_team(player.team_id),
         {:ok, true} <- Teams.verify_owner(team, user.id),
         {:ok, updated_player} <- Players.update_player(player, params) do
      render(conn, "show.json", %{player: updated_player})
    end
  end

  def buy(conn, %{"player_id" => player_id}) do
    with %User{} = user <- Authentication.get_current_account(conn),
         {:ok, team} <- Teams.get_team_by_user(user.id),
         {:ok, _} <- Players.transfer_player(player_id, team.id),
         {:ok, player} <- Players.get_player(player_id) do
      render(conn, "show.json", %{player: player})
    end
  end
end
