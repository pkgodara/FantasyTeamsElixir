defmodule FantasyWeb.TeamsView do
  use FantasyWeb, :view

  def render("show.json", %{team: team}) do
    %{
      id: team.id,
      name: team.name,
      owner: team.user_id,
      country: team.country,
      budget: team.budget,
      inserted_at: team.inserted_at,
      updated_at: team.updated_at
    }
  end

  def render("show.json", %{team_players: team}) do
    %{
      id: team.id,
      name: team.name,
      owner: team.user_id,
      country: team.country,
      budget: team.budget,
      value: team.value,
      inserted_at: team.inserted_at,
      updated_at: team.updated_at,
      players: render_many(team.players, FantasyWeb.PlayersView, "show.json", as: :player)
    }
  end
end
