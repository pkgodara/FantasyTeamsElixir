defmodule Fantasy.UsersTest do
  use Fantasy.DataCase

  alias Fantasy.Users

  setup do
    {:ok, user: insert(:user)}
  end

  describe "users" do
    alias Fantasy.Users.User

    @invalid_attrs %{email: nil}

    test "get_user!/1 returns the user with given id", %{user: user} do
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = params_for(:user)

      assert {:ok, %User{}} = Users.create_user(valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user", %{user: user} do
      update_attrs = %{}

      assert {:ok, %User{}} = Users.update_user(user, update_attrs)
    end

    test "update_user/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "get_user_by_email/1 gets user successfully", %{user: user} do
      assert {:ok, ^user} = Users.get_user_by_email(user.email)
    end

    test "get_user_by_email/1 returns not_found" do
      assert {:error, :not_found} = Users.get_user_by_email("some@email.com")
    end
  end

  describe "signup/1" do
    test "successfully creates user with team and players" do
      %{email: email} = params = params_for(:user)
      assert {:ok, result} = Users.signup(params)
      assert %{id: user_id, email: ^email} = result[:user]
      assert %{id: team_id, user_id: ^user_id, budget: 5_000_000} = result[:team]

      Enum.each(Users.get_player_roles(), fn {role, k} ->
        assert %{team_id: ^team_id, market_value: 1_000_000} = result[{:player, {role, k}}]
      end)
    end

    test "error on invalid email" do
      params = params_for(:user, email: "some.nothing")

      assert {:error, %Ecto.Changeset{errors: [email: {"invalid email", []}]}} =
               Users.signup(params)
    end
  end
end
