defmodule FantasyWeb.PlayersView do
  use FantasyWeb, :view

  def render("show.json", %{player: player}) do
    %{
      id: player.id,
      team: player.team_id,
      first_name: player.fname,
      last_name: player.lname,
      age: player.age,
      country: player.country,
      role: player.role,
      market_value: player.market_value,
      inserted_at: player.inserted_at,
      updated_at: player.updated_at
    }
  end
end
