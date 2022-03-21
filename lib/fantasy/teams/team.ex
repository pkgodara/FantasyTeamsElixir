defmodule Fantasy.Teams.Team do
  @moduledoc """
  Schema for Team
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Fantasy.Players.Player

  @required_fields [:budget, :user_id]
  @optional_fields [:country, :name]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "teams" do
    field :user_id, Ecto.UUID
    field :budget, :integer, default: 5_000_000
    field :country, :string
    field :name, :string

    has_many :players, Player

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end

  def update_changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :country])
    |> validate_required([:name, :country])
  end
end
