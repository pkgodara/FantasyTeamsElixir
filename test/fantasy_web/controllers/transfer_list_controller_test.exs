defmodule FantasyWeb.TransferListControllerTest do
  use FantasyWeb.ConnCase, async: true

  describe "list/2" do
    setup do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      player = insert(:player, team_id: team.id)
      transfer_list = insert(:transfer_list, player_id: player.id, user_id: user.id)

      {:ok, user: user, player: player, transfer_list: transfer_list}
    end

    test "successfully list players on auction-list", %{
      conn: conn,
      user: user,
      transfer_list: transfer_list
    } do
      %{player_id: player_id, user_id: user_id, ask_price: ask_price} = transfer_list

      conn =
        conn
        |> authorize_conn(user)
        |> get(Routes.transfer_list_path(conn, :list))

      assert %{
               "page_number" => 1,
               "page_size" => 10,
               "total_entries" => 1,
               "total_pages" => 1,
               "entries" => [
                 entry
               ]
             } = json_response(conn, 200)

      assert %{"ask_price" => ^ask_price, "owner" => ^user_id, "player_id" => ^player_id} = entry
    end

    test "error without login", %{conn: conn} do
      conn = get(conn, Routes.transfer_list_path(conn, :list))
      assert %{"error" => "Authentication error."} = json_response(conn, 401)
    end
  end

  describe "auction/2" do
    setup do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      player = insert(:player, team_id: team.id)

      {:ok, user: user, player: player}
    end

    test "successfully put player on auction-list", %{conn: conn, user: user, player: player} do
      %{id: user_id} = user
      %{id: player_id} = player
      ask_price = 1_100_000

      params = %{player_id: player_id, ask_price: ask_price}

      conn =
        conn
        |> authorize_conn(user)
        |> post(Routes.transfer_list_path(conn, :auction), params)

      assert %{"ask_price" => ^ask_price, "owner" => ^user_id, "player_id" => ^player_id} =
               json_response(conn, 200)
    end

    test "error trying to put un-owned player on auction-list", %{conn: conn, user: user} do
      user2 = insert(:user)
      team2 = insert(:team, user_id: user2.id)
      player2 = insert(:player, team_id: team2.id)
      ask_price = 1_100_000

      params = %{player_id: player2.id, ask_price: ask_price}

      conn =
        conn
        |> authorize_conn(user)
        |> post(Routes.transfer_list_path(conn, :auction), params)

      assert %{"errors" => %{"detail" => "Bad Request", "reason" => "team_not_owned"}} =
               json_response(conn, 400)
    end

    test "error without login", %{conn: conn} do
      conn = post(conn, Routes.transfer_list_path(conn, :auction))
      assert %{"error" => "Authentication error."} = json_response(conn, 401)
    end
  end
end
