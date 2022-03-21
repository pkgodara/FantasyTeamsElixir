defmodule Fantasy.TransferListTest do
  use Fantasy.DataCase

  alias Fantasy.TransferList
  alias Fantasy.Schema.TransferList, as: Transfer

  setup do
    user = insert(:user)
    team = insert(:team, user_id: user.id)
    player = insert(:player, team_id: team.id)

    {:ok,
     user: user,
     player: player,
     transfer_list: insert(:transfer_list, user_id: user.id, player_id: player.id)}
  end

  describe "transfer_list" do
    @invalid_attrs %{}

    test "create_transfer_list/1 with valid data creates a transfer_list" do
      user = insert(:user)
      team = insert(:team, user_id: user.id)
      player = insert(:player, team_id: team.id)
      valid_attrs = params_for(:transfer_list, user_id: user.id, player_id: player.id)

      assert {:ok, %Transfer{}} = TransferList.create_transfer(valid_attrs)
    end

    test "create_transfer_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TransferList.create_transfer(@invalid_attrs)
    end
  end
end
