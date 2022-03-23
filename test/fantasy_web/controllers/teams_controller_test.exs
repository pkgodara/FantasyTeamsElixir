defmodule FantasyWeb.TeamsControllerTest do
  use FantasyWeb.ConnCase, async: true

  describe "list/2" do
    setup do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      player = insert(:player, team_id: team.id)
      {:ok, user: user, team: team, player: player}
    end

    test "successfully list team with players and value", %{
      conn: conn,
      user: user,
      team: team,
      player: player
    } do
      conn =
        conn
        |> authorize_conn(user)
        |> get(Routes.teams_path(conn, :list))

      %{id: user_id} = user
      %{id: team_id} = team
      %{id: player_id} = player

      assert %{"id" => ^team_id, "owner" => ^user_id, "players" => result_players} =
               json_response(conn, 200)

      assert [%{"id" => ^player_id, "team" => ^team_id}] = result_players
    end

    test "error without login", %{conn: conn} do
      conn = get(conn, Routes.teams_path(conn, :list))
      assert %{"error" => "Authentication error."} = json_response(conn, 401)
    end
  end

  describe "update/2" do
    setup do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      {:ok, user: user, team: team}
    end

    test "successfully update team data", %{conn: conn, user: user, team: team} do
      %{id: user_id} = user
      %{id: team_id} = team
      name = "new_team_name"

      params = %{"name" => name}

      conn =
        conn
        |> authorize_conn(user)
        |> put(Routes.teams_path(conn, :update, team_id), params)

      assert %{"id" => ^team_id, "owner" => ^user_id, "name" => ^name} = json_response(conn, 200)
    end

    test "error updating team not owned", %{conn: conn, user: user} do
      user2 = insert(:user)
      team2 = insert(:team, user_id: user2.id)

      conn =
        conn
        |> authorize_conn(user)
        |> put(Routes.teams_path(conn, :update, team2.id), %{})

      assert %{"errors" => %{"detail" => "Bad Request", "reason" => "team_not_owned"}} =
               json_response(conn, 400)
    end

    test "error without login", %{conn: conn} do
      conn = put(conn, Routes.teams_path(conn, :update, Ecto.UUID.generate()))
      assert %{"error" => "Authentication error."} = json_response(conn, 401)
    end
  end
end
