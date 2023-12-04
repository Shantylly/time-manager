defmodule Todolist.Repo.Migrations.CreateTimespents do
  use Ecto.Migration

  def change do
    create table(:timespents) do
      add :date_start, :string
      add :date_end, :string
      add :description, :string
      add :user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
