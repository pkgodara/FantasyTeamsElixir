defmodule Fantasy.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Fantasy.Repo

  alias Fantasy.Teams.Team

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  @doc """
  Gets a team by id
  """
  def get_team(id) do
    Team
    |> by_id(id)
    |> fetch_one()
  end

  @doc """
  Gets a team by Owner - user_id
  """
  def get_team_by_user(user_id) do
    Team
    |> by_user_id(user_id)
    |> fetch_one()
  end

  @doc """
  List team and players for given owner - user_id
  """
  def list_team_players(user_id) do
    with {:ok, team_players} <- get_team_players_by_user(user_id) do
      total_value =
        Enum.reduce(team_players.players, 0, fn %{market_value: market_value}, acc ->
          market_value + acc
        end)

      {:ok, Map.put(team_players, :value, total_value)}
    end
  end

  @doc """
  Verify team owner
  """
  def verify_owner(team, user_id) do
    if team.user_id === user_id do
      {:ok, true}
    else
      {:error, :team_not_owned}
    end
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Restricted updates, To be used publically
  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.update_changeset(attrs)
    |> Repo.update()
  end

  # Private functions
  defp by_id(query, id) do
    where(query, [r], r.id == ^id)
  end

  defp fetch_one(query) do
    case Repo.one(query) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  defp get_team_players_by_user(user_id) do
    Team
    |> by_user_id(user_id)
    |> preload(:players)
    |> fetch_one()
  end

  defp by_user_id(query, user_id) do
    where(query, [r], r.user_id == ^user_id)
  end
end
