defmodule Todolist.Repo.Migrations.CreateClocks do
  use Ecto.Migration

  def change do
    create table(:clocks) do
      add :time, :utc_datetime
      add :status, :boolean, default: false, null: false
      add :user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
