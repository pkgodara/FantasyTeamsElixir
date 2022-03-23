defmodule Fantasy.PlayersTest do
  use Fantasy.DataCase

  alias Fantasy.Players
  alias Fantasy.Players.Player
  alias Fantasy.Teams
  alias Fantasy.TransferList

  describe "players" do
    setup do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      {:ok, team: team, player: insert(:player, team_id: team.id)}
    end

    @invalid_attrs %{fname: 12}

    test "get_player!/1 returns the player with given id", %{player: player} do
      assert Players.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player", %{team: team} do
      valid_attrs = params_for(:player, team_id: team.id)

      assert {:ok, %Player{}} = Players.create_player(valid_attrs)
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Players.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player", %{player: player} do
      update_attrs = %{}

      assert {:ok, %Player{}} = Players.update_player(player, update_attrs)
    end

    test "update_player/2 with invalid data returns error changeset", %{player: player} do
      assert {:error, %Ecto.Changeset{}} = Players.update_player(player, @invalid_attrs)
      assert player == Players.get_player!(player.id)
    end
  end

  describe "transfer_player/2" do
    setup do
      user1 = insert(:user)
      user2 = insert(:user)
      team1 = insert(:team, user_id: user1.id)
      team2 = insert(:team, user_id: user2.id)
      player = insert(:player, team_id: team1.id)
      transfer_list = insert(:transfer_list, user_id: user1.id, player_id: player.id)

      {:ok,
       user1: user1,
       user2: user2,
       team1: team1,
       team2: team2,
       player: player,
       transfer_list: transfer_list}
    end

    test "successfully transfer player to another team", %{
      team1: team1,
      team2: team2,
      player: player,
      transfer_list: transfer_list
    } do
      %{market_value: old_market_value} = player
      %{ask_price: ask_price} = transfer_list
      new_team1_budget = team1.budget + ask_price
      new_team2_budget = team2.budget - ask_price

      assert {:ok, result} = Players.transfer_player(player.id, team2.id)

      assert result[:updated_player].market_value > old_market_value
      assert result[:old_updated_team].budget == new_team1_budget
      assert result[:new_updated_team].budget == new_team2_budget

      assert {:ok, %{budget: ^new_team1_budget}} = Teams.get_team(team1.id)
      assert {:ok, %{id: team2_id, budget: ^new_team2_budget}} = Teams.get_team(team2.id)
      assert {:error, :not_found} = TransferList.get_transfer_list(player.id)

      assert {:ok, %{market_value: new_market_value, team_id: ^team2_id}} =
               Players.get_player(player.id)

      assert new_market_value == result[:updated_player].market_value
    end

    test "error on transferring player to same team", %{
      team1: team1,
      team2: team2,
      player: player,
      transfer_list: transfer_list
    } do
      assert {:error, :cannot_transfer_to_existing_team} =
               Players.transfer_player(player.id, team1.id)

      assert {:ok, ^transfer_list} = TransferList.get_transfer_list(player.id)
      assert {:ok, ^player} = Players.get_player(player.id)
      assert {:ok, ^team1} = Teams.get_team(team1.id)
      assert {:ok, ^team2} = Teams.get_team(team2.id)
    end

    test "error on buying player with insufficient budget", %{
      team1: team1,
      user2: user2,
      player: player,
      transfer_list: transfer_list
    } do
      team2 = insert(:team, user_id: user2.id, budget: 1_000)
      assert {:error, :budget_not_enough} = Players.transfer_player(player.id, team2.id)

      assert {:ok, ^transfer_list} = TransferList.get_transfer_list(player.id)
      assert {:ok, ^player} = Players.get_player(player.id)
      assert {:ok, ^team1} = Teams.get_team(team1.id)
      assert {:ok, ^team2} = Teams.get_team(team2.id)
    end

    test "error when non-existant player_id given", %{
      team2: team2
    } do
      assert {:error, :not_found} = Players.transfer_player(Ecto.UUID.generate(), team2.id)

      assert {:ok, ^team2} = Teams.get_team(team2.id)
    end

    test "error when non-existent team_id given", %{
      team1: team1,
      player: player,
      transfer_list: transfer_list
    } do
      assert {:error, :not_found} = Players.transfer_player(player.id, Ecto.UUID.generate())

      assert {:ok, ^transfer_list} = TransferList.get_transfer_list(player.id)
      assert {:ok, ^player} = Players.get_player(player.id)
      assert {:ok, ^team1} = Teams.get_team(team1.id)
    end
  end
end
