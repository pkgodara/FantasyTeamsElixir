defmodule Fantasy.Schema.TransferList do
  @moduledoc """
  Schema for Transfer-List
  """
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:user_id, :player_id, :ask_price]

  @primary_key false
  schema "transfer_list" do
    field :ask_price, :integer
    field :user_id, Ecto.UUID
    field :player_id, Ecto.UUID, primary_key: true

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(transfer_list, attrs) do
    transfer_list
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:player_id)
    |> unique_constraint(:player_id, name: :transfer_list_pkey)
  end
end
