defmodule Fantasy.Repo.Migrations.CreateTransferList do
  use Ecto.Migration

  def change do
    create table(:transfer_list, primary_key: false) do
      add :ask_price, :integer, null: false
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
      add :player_id, references(:players, type: :uuid, on_delete: :nothing), primary_key: true

      timestamps(type: :utc_datetime_usec)
    end
  end
end
