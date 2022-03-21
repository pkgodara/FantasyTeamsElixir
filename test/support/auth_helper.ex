defmodule Fantasy.Test.Support.Auth do
  @moduledoc """
  Auth support functions
  """

  import Plug.Conn
  alias FantasyWeb.Authentication

  def authorize_conn(conn, user) do
    {:ok, token, _} = Authentication.encode_and_sign(user, %{}, token_type: :access)

    put_req_header(conn, "authorization", "Bearer " <> token)
  end
end
