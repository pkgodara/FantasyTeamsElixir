defmodule Fantasy.Repo do
  use Ecto.Repo,
    otp_app: :fantasy,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
