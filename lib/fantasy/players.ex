defmodule Fantasy.Players do
  @moduledoc """
  The Players context.
  """

  import Ecto.Query, warn: false

  alias Fantasy.Repo
  alias Ecto.Multi
  alias Fantasy.TransferList
  alias Fantasy.Teams
  alias Fantasy.Players
  alias Fantasy.Players.Player

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Gets a player
  """
  def get_player(player_id) do
    Player
    |> by_player_id(player_id)
    |> fetch_one()
  end

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player. use internally
  """
  def update(%Player{} = player, attrs \\ %{}) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a Player, Restricted fields only. To be used publically

  ## Examples

      iex> update(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Transfer a player on transfer-list

  Increases old team budget,
  Decreases new team budget,
  Increases Player market-value,
  Removes Player from auction list
  """
  def transfer_player(player_id, new_team_id) do
    Multi.new()
    |> Multi.run(:player, fn _, _ ->
      get_player(player_id)
    end)
    |> Multi.run(:old_team, fn _, %{player: player} ->
      Teams.get_team(player.team_id)
    end)
    |> Multi.run(:new_team, fn _, _ ->
      Teams.get_team(new_team_id)
    end)
    |> Multi.run(:verified_teams, fn _, %{old_team: old_team, new_team: new_team} ->
      if old_team.id === new_team.id do
        {:error, :cannot_transfer_to_existing_team}
      else
        {:ok, true}
      end
    end)
    |> Multi.run(:transfer_list, fn _, %{player: player} ->
      case TransferList.get_transfer_list(player.id) do
        {:ok, tl} -> TransferList.delete_transfer_list(tl)
        {:error, :not_found} -> {:error, :player_not_on_auction}
      end
    end)
    |> Multi.run(:new_updated_team, fn _, %{new_team: new_team, transfer_list: transfer_list} ->
      if new_team.budget >= transfer_list.ask_price do
        Teams.update(new_team, %{budget: new_team.budget - transfer_list.ask_price})
      else
        {:error, :budget_not_enough}
      end
    end)
    |> Multi.run(:updated_player, fn _, %{player: player} ->
      increment = Enum.random(10..100)
      new_market_value = ceil(player.market_value + player.market_value * increment / 100)
      Players.update(player, %{team_id: new_team_id, market_value: new_market_value})
    end)
    |> Multi.run(:old_updated_team, fn _, %{transfer_list: transfer_list, old_team: old_team} ->
      Teams.update(old_team, %{budget: old_team.budget + transfer_list.ask_price})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result}

      {:error, _failed_operation, failed_value, _changes} ->
        {:error, failed_value}
    end
  end

  # Private functions
  defp by_player_id(query, player_id) do
    where(query, [r], r.id == ^player_id)
  end

  defp fetch_one(query) do
    case Repo.one(query) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
