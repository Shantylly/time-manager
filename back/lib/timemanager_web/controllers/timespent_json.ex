defmodule TodolistWeb.TimespentJSON do
  alias Todolist.Timespents.Timespent

  @doc """
  Renders a list of timespents.
  """
  def index(%{timespents: timespents}) do
    %{data: for(timespent <- timespents, do: data(timespent))}
  end

  @doc """
  Renders a single timespent.
  """
  def show(%{timespent: timespent}) do
    %{data: data(timespent)}
  end

  defp data(%Timespent{} = timespent) do
    %{
      id: timespent.id,
      date_start: timespent.date_start,
      date_end: timespent.date_end,
      description: timespent.description,
      user_id: timespent.user_id
    }
  end
end
