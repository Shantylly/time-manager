defmodule Todolist.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :firstname, :lastname, :address, :role, :mail, :phone, :team_id, :password, :genre]}
  schema "users" do
    field :address, :string
    field :role, :string
    field :mail, :string
    field :firstname, :string
    field :lastname, :string
    field :phone, :string
    field :password, :string
    field :genre, :string

    belongs_to :team, Todolist.Teams.Team, foreign_key: :team_id, references: :id, type: :integer
    has_many :teams, Todolist.Teams.Team, foreign_key: :manager_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:firstname, :lastname, :role, :team_id, :address, :mail, :phone, :password, :genre])
    |> validate_required([:firstname, :lastname, :role, :address, :mail, :phone, :password, :genre])
    |> validate_format(:mail, ~r/^[^\s]+@[^\s]+$/, message: "must have @ and no space")
    |> unique_constraint(:mail)
    |> unique_constraint(:phone)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: hash_password}} = changeset) do
    change(changeset, password: Bcrypt.hash_pwd_salt(hash_password))
  end

  defp put_password_hash(changeset), do: changeset
end
