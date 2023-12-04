defmodule Todolist.TimespentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todolist.Timespents` context.
  """

  @doc """
  Generate a timespent.
  """
  def timespent_fixture(attrs \\ %{}) do
    {:ok, timespent} =
      attrs
      |> Enum.into(%{
        date_end: "some date_end",
        date_start: "some date_start",
        description: "some description",
        user_id: 42
      })
      |> Todolist.Timespents.create_timespent()

    timespent
  end
end
