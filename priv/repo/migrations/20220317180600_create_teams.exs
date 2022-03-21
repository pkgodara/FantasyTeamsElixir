defmodule Fantasy.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
      add :name, :string
      add :country, :string
      add :budget, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
