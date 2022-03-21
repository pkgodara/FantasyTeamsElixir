defmodule FantasyWeb.TransferListView do
  use FantasyWeb, :view

  def render("show.json", %{page: page}) do
    %{
      page_number: page.page_number,
      page_size: page.page_size,
      total_entries: page.total_entries,
      total_pages: page.total_pages,
      entries: render_many(page.entries, __MODULE__, "show.json", as: :transfer_list)
    }
  end

  def render("show.json", %{transfer_list: transfer_list}) do
    %{
      player_id: transfer_list.player_id,
      owner: transfer_list.user_id,
      ask_price: transfer_list.ask_price,
      inserted_at: transfer_list.inserted_at,
      updated_at: transfer_list.updated_at
    }
  end
end
