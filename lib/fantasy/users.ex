defmodule Fantasy.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false

  alias Fantasy.Repo
  alias Fantasy.Users.User
  alias Fantasy.Teams
  alias Fantasy.Factory
  alias Fantasy.Players
  alias Ecto.Multi

  @team_player_roles [
    goalkeeper: 3,
    defender: 6,
    midfielder: 6,
    attacker: 5
  ]

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Geta a user for given Email
  """
  def get_user_by_email(email) do
    User
    |> by_email(email)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Verifies the given plain-text password matches to db password_hash
  """
  def verify_password(user, passwd) do
    Argon2.check_pass(user, passwd)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Signup Customer

  Create a user,
  Create a team for user,
  Create 20 Players for team
  """
  def signup(attrs) do
    Multi.new()
    |> Multi.run(:user, fn _, _ ->
      create_user(attrs)
    end)
    |> Multi.run(:team, fn _, %{user: user} ->
      Teams.create_team(Factory.params_for(:team, user_id: user.id))
    end)
    |> insert_players()
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result}

      {:error, _failed_operation, failed_value, _changes} ->
        {:error, failed_value}
    end
  end

  @doc """
  List all player roles, with counter
  """
  def get_player_roles() do
    Enum.flat_map(@team_player_roles, fn {player_role, num_players} ->
      Enum.map(1..num_players, fn k ->
        {player_role, k}
      end)
    end)
  end

  # Private functions
  defp insert_players(multi) do
    Enum.reduce(get_player_roles(), multi, fn {player_role, id}, multi ->
      multi
      |> Multi.run({:player, {player_role, id}}, fn _, %{team: team} ->
        Players.create_player(Factory.params_for(:player, team_id: team.id, role: player_role))
      end)
    end)
  end

  defp by_email(q, email) do
    where(q, [r], r.email == ^email)
  end
end
