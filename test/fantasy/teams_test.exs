defmodule Fantasy.TeamsTest do
  use Fantasy.DataCase

  alias Fantasy.Teams

  setup do
    user = insert(:user)
    {:ok, team: insert(:team, user_id: user.id)}
  end

  describe "teams" do
    alias Fantasy.Teams.Team

    @invalid_attrs %{budget: nil}

    test "get_team!/1 returns the team with given id", %{team: team} do
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      user = insert(:user)
      valid_attrs = params_for(:team, user_id: user.id)

      assert {:ok, %Team{}} = Teams.create_team(valid_attrs)
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team", %{team: team} do
      update_attrs = %{}

      assert {:ok, %Team{}} = Teams.update_team(team, update_attrs)
    end
  end
end
