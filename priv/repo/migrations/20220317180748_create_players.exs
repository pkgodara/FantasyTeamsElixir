defmodule Fantasy.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :team_id, references(:teams, type: :uuid, on_delete: :nothing)
      add :fname, :string
      add :lname, :string
      add :country, :string
      add :age, :integer
      add :market_value, :integer, null: false
      add :role, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
