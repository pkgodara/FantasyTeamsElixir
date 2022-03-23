defmodule Fantasy.Players.Player do
  @moduledoc """
  Schema for Player
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Fantasy.Teams.Team

  @roles ~w[
          goalkeeper
          defender
          midfielder
          attacker
        ]a

  @required_fields [:team_id, :fname, :lname, :country, :age, :market_value, :role]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "players" do
    field :age, :integer
    field :country, :string
    field :fname, :string
    field :lname, :string
    field :market_value, :integer, default: 1_000_000
    field :role, Ecto.Enum, values: @roles

    belongs_to :team, Team

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:team_id)
  end

  def update_changeset(player, attrs) do
    player
    |> cast(attrs, [:fname, :lname, :country])
    |> validate_required([:fname, :lname, :country])
  end
end
