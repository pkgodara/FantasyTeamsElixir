defmodule Fantasy.Factory do
  @moduledoc """
  Factories for database records, to use in our test suite
  """
  use ExMachina.Ecto, repo: Fantasy.Repo

  alias Fantasy.Users.User
  alias Fantasy.Teams.Team
  alias Fantasy.Players.Player
  alias Fantasy.Schema.TransferList

  def user_factory(attrs) do
    user = %User{
      id: Ecto.UUID.generate(),
      email: Faker.Internet.email(),
      password_hash: "random_hash",
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    merge_attributes(user, attrs)
  end

  def team_factory(attrs) do
    team = %Team{
      id: Ecto.UUID.generate(),
      user_id: Ecto.UUID.generate(),
      name: Faker.Pokemon.name(),
      budget: 5_000_000,
      country: Faker.Address.En.country(),
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    merge_attributes(team, attrs)
  end

  def player_factory(attrs) do
    player = %Player{
      id: Ecto.UUID.generate(),
      team_id: Ecto.UUID.generate(),
      fname: Faker.Person.first_name(),
      lname: Faker.Person.last_name(),
      age: Enum.random(18..40),
      market_value: 1_000_000,
      country: Faker.Address.En.country(),
      role:
        Enum.random([
          :goalkeeper,
          :defender,
          :midfielder,
          :attacker
        ]),
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    merge_attributes(player, attrs)
  end

  def transfer_list_factory(attrs) do
    transfer_list = %TransferList{
      player_id: Ecto.UUID.generate(),
      user_id: Ecto.UUID.generate(),
      ask_price: 1_000_100,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    merge_attributes(transfer_list, attrs)
  end
end
