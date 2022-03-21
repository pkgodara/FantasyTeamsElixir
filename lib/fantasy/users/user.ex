defmodule Fantasy.Users.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Fantasy.Teams.Team

  @required_fields [:email, :password_hash]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :password_hash, :string

    has_one :team, Team

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> put_encrypted_password(attrs[:password])
    |> validate_required(@required_fields)
    |> validate_email()
    |> unique_constraint(:email, name: :users_email_index)
  end

  defp put_encrypted_password(changeset, nil), do: changeset
  defp put_encrypted_password(changeset, ""), do: changeset

  defp put_encrypted_password(changeset, pw) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(pw))
  end

  defp validate_email(%Ecto.Changeset{changes: %{email: email}} = changeset) do
    if is_valid_email?(email) do
      changeset
    else
      add_error(changeset, :email, "invalid email")
    end
  end

  defp validate_email(changeset), do: changeset

  @email_validation_regex ~r/^[\w.!#$%&'*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i

  def is_valid_email?(email) do
    String.match?(email, @email_validation_regex)
  end
end
