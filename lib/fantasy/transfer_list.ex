defmodule Fantasy.TransferList do
  @moduledoc """
  The TransferList context.
  """

  import Ecto.Query, warn: false

  alias Fantasy.Repo
  alias Fantasy.Schema.TransferList

  @doc """
  Returns the list of transfer_list.

  ## Examples

      iex> list_transfer_list()
      [%TransferList{}, ...]

  """
  def list(params \\ %{}) do
    params = Map.put(params, "page_size", 10)

    TransferList
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(params)
  end

  @doc """
  Gets a transfer-list entry, throws exception if not found
  """
  def get_transfer_list!(player_id), do: Repo.one!(TransferList, player_id)

  @doc """
  Gets a transfer-list entry
  """
  def get_transfer_list(player_id) do
    TransferList
    |> by_player_id(player_id)
    |> fetch_one()
  end

  @doc """
  Creates a transfer.

  ## Examples

      iex> create_transfer(%{field: value})
      {:ok, %TransferList{}}

      iex> create_transfer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transfer(attrs \\ %{}) do
    %TransferList{}
    |> TransferList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a transfer_list.

  ## Examples

      iex> delete_transfer_list(transfer_list)
      {:ok, %TransferList{}}

      iex> delete_transfer_list(transfer_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transfer_list(%TransferList{} = transfer_list) do
    Repo.delete(transfer_list)
  end

  # Private fns
  defp by_player_id(query, player_id) do
    where(query, [r], r.player_id == ^player_id)
  end

  defp fetch_one(query) do
    case Repo.one(query) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
