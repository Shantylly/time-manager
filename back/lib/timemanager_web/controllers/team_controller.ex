defmodule TodolistWeb.TeamController do
  use TodolistWeb, :controller

  alias Todolist.Teams
  alias Todolist.Teams.Team

  import Ecto.Query

  action_fallback TodolistWeb.FallbackController

  def index(conn, _params) do
    teams = Teams.list_teams()
    render(conn, :index, teams: teams)
  end

  def list_users_by_team(conn, _params) do
    teams_with_user_count =
      from(t in Todolist.Teams.Team,
        left_join: u in Todolist.Users.User, on: u.team_id == t.id,
        group_by: t.id,
        select: %{team_id: t.id, user_count: count(u.id)}
      )
      |> Todolist.Repo.all()

    conn
    |> put_status(:ok)
    |> json(%{teams: teams_with_user_count})
  end

  def create(conn, %{"name" => name,"manager_id" => manager_id}) do
    team_params = %{
      name: name,
      manager_id: manager_id
    }
    with {:ok, %Team{} = team} <- Teams.create_team(team_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/teams/#{team}")
      |> render(:show, team: team)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Teams.get_team!(id)
    render(conn, :show, team: team)
  end

  def update(conn, %{"id" => id} = team_params) do
    team = Teams.get_team!(id)

    with {:ok, %Team{} = team} <- Teams.update_team(team, team_params) do
      render(conn, :show, team: team)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{}} <- Teams.delete_team(team) do
      send_resp(conn, :no_content, "")
    end
  end

  def list_users_for_each_team(conn, _params) do
    teams = Todolist.Teams.list_teams_users()

      IO.inspect (teams)

    render(conn, :indexUsers, teams: teams)
  end

end
