defmodule FantasyWeb.PlayersControllerTest do
  use FantasyWeb.ConnCase, async: true

  describe "update/2" do
    setup do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      player = insert(:player, team_id: team.id)
      {:ok, user: user, team: team, player: player}
    end

    test "successfully update a player", %{conn: conn, user: user, team: team, player: player} do
      %{id: team_id} = team
      %{id: player_id} = player
      fname = "new-first-name"

      params = %{"fname" => fname}

      conn =
        conn
        |> authorize_conn(user)
        |> put(Routes.players_path(conn, :update, player_id), params)

      assert %{"id" => ^player_id, "team" => ^team_id, "first_name" => ^fname} =
               json_response(conn, 200)
    end

    test "error updating un-owned team player", %{conn: conn, user: user} do
      user2 = insert(:user)
      team2 = insert(:team, user_id: user2.id)
      player2 = insert(:player, team_id: team2.id)

      conn =
        conn
        |> authorize_conn(user)
        |> put(Routes.players_path(conn, :update, player2.id), %{})

      assert %{"errors" => %{"detail" => "Bad Request", "reason" => "team_not_owned"}} =
               json_response(conn, 400)
    end

    test "error without login", %{conn: conn} do
      conn = put(conn, Routes.players_path(conn, :update, Ecto.UUID.generate()))
      assert %{"error" => "Authentication error."} = json_response(conn, 401)
    end
  end

  describe "buy/2" do
    setup do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      player = insert(:player, team_id: team.id)
      transfer_list = insert(:transfer_list, player_id: player.id, user_id: user.id)

      new_user = insert(:user)
      new_team = insert(:team, user_id: new_user.id)

      {:ok,
       user: user,
       team: team,
       player: player,
       transfer_list: transfer_list,
       new_user: new_user,
       new_team: new_team}
    end

    test "successfully buy player", %{
      conn: conn,
      player: player,
      new_user: new_user,
      new_team: new_team
    } do
      %{id: player_id} = player
      %{id: new_team_id} = new_team

      conn =
        conn
        |> authorize_conn(new_user)
        |> post(Routes.players_path(conn, :buy, player_id))

      assert %{"id" => ^player_id, "team" => ^new_team_id} = json_response(conn, 200)
    end

    test "error without login", %{conn: conn} do
      conn = post(conn, Routes.players_path(conn, :buy, Ecto.UUID.generate()))
      assert %{"error" => "Authentication error."} = json_response(conn, 401)
    end
  end
end
