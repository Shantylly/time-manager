defmodule Todolist.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todolist.Teams` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        manager_id: 42,
        name: "some name"
      })
      |> Todolist.Teams.create_team()

    team
  end
end
