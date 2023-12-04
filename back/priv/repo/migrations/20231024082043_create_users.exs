defmodule Todolist.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :firstname, :string
      add :lastname, :string
      add :role, :string
      add :team_id, :integer
      add :address, :string
      add :mail, :string
      add :phone, :string
      add :password, :string
      add :genre, :string

      timestamps(type: :utc_datetime)

    end
    create unique_index(:users, [:mail])
    create unique_index(:users, [:phone])
  end
end
