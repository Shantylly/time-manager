defmodule Todolist.Timespents.Timespent do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :description, :date_start, :date_end, :user_id]}
  schema "timespents" do
    field :description, :string
    field :date_start, :string
    field :date_end, :string
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(timespent, attrs) do
    timespent
    |> cast(attrs, [:date_start, :date_end, :description, :user_id])
    |> validate_required([:date_start, :date_end, :description, :user_id])
  end
end
