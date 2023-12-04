defmodule Todolist.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string

    has_many :users, Todolist.Users.User, foreign_key: :team_id
    belongs_to :user, Todolist.Users.User, foreign_key: :manager_id, references: :id, type: :integer
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :manager_id])
    |> validate_required([:name, :manager_id])
  end
end
