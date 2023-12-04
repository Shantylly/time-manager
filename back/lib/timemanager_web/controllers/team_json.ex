defmodule TodolistWeb.TeamJSON do
  alias Todolist.Teams.Team
  alias TodolistWeb.UserJSON

  @doc """
  Renders a list of teams.
  """
  def index(%{teams: teams}) do
    %{data: for(team <- teams, do: data(team))}
  end

  def indexUsers(%{teams: teams}) do
    %{data: for(team <- teams, do: dataUsers(team))}
  end

  @doc """
  Renders a single team.
  """
  def show(%{team: team}) do
    %{data: data(team)}
  end

  defp data(%Team{} = team) do
    %{
      id: team.id,
      name: team.name,
      manager_id: team.manager_id
    }
  end

  defp dataUsers(%Team{} = team) do
    %{
      id: team.id,
      name: team.name,
      manager_id: team.manager_id,
      users: for(user <- team.users, do: UserJSON.show(%{user: user}))
    }
  end
end
