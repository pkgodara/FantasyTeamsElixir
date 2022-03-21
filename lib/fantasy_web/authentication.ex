defmodule FantasyWeb.Authentication do
  @moduledoc """
  API Authentication
  """
  use Guardian, otp_app: :fantasy

  alias Fantasy.Users

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user!(id) do
      nil -> {:error, :resource_not_found}
      account -> {:ok, account}
    end
  end

  def log_in(conn, account) do
    __MODULE__.Plug.sign_in(conn, account)
  end

  def get_current_account(conn) do
    __MODULE__.Plug.current_resource(conn)
  end
end
