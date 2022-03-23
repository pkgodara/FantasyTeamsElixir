defmodule FantasyWeb.TransferListController do
  @moduledoc tags: ["Transfer-List"]

  use FantasyWeb, :controller

  alias Fantasy.Players
  alias Fantasy.TransferList
  alias Fantasy.Users.User
  alias Fantasy.Teams
  alias FantasyWeb.Authentication

  def list(conn, params) do
    with %User{} = _user <- Authentication.get_current_account(conn),
         %Scrivener.Page{} = page <- TransferList.list(params) do
      render(conn, "show.json", %{page: page})
    end
  end

  def auction(conn, %{"player_id" => player_id, "ask_price" => ask_price}) do
    with %User{} = user <- Authentication.get_current_account(conn),
         {:ok, player} <- Players.get_player(player_id),
         {:ok, team} <- Teams.get_team(player.team_id),
         {:ok, true} <- Teams.verify_owner(team, user.id),
         {:ok, transfer} <-
           TransferList.create_transfer(%{
             user_id: user.id,
             player_id: player_id,
             ask_price: ask_price
           }) do
      render(conn, "show.json", %{transfer_list: transfer})
    end
  end
end
