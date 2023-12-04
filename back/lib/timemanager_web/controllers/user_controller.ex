defmodule TodolistWeb.UserController do
  use TodolistWeb, :controller

  alias Todolist.Users
  alias Todolist.Users.User
  alias Todolist.Repo

  import Ecto.Query

  action_fallback TodolistWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"address" => address, "role" => role, "mail" => mail, "firstname" => firstname, "lastname" => lastname, "phone" => phone, "password" => password, "genre" => genre}) do
    user_params = %{
      address: address,
      role: role,
      mail: mail,
      firstname: firstname,
      lastname: lastname,
      team_id: nil,
      phone: phone,
      password: password,
      genre: genre
    }

    with {:ok, %User{} = user} <- Users.create_user(user_params),
        {:ok, token, _claims} <- TodoListWeb.Auth.Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user.id}")
      |> json(%{user: user, token: token})
    end
  end

  def sign_in(conn, %{"mail" => mail, "password" => password}) do
    case TodoListWeb.Auth.Guardian.auth(mail,password) do
      {:ok, user, token} ->
        conn
        |> put_status(:ok)
        |> json(%{user: user, token: token})
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication failed"})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id} = user_params) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def index_by_team(conn, %{"team_id" => team_id}) do
    IO.inspect team_id, label: "Received team_id"  # Debugging statement

    # Check if the team with the specified ID exists
    case Repo.get(Todolist.Teams.Team, String.to_integer(team_id)) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      _ ->
        # Fetch users with the specified team_id from the database
        query = from(u in User, where: u.team_id == ^String.to_integer(team_id))
        users = Repo.all(query)

        IO.inspect users, label: "Query Result"  # Debugging statement

        # Respond with the list of users
        conn
        |> put_status(:ok)
        |> json(%{users: users})
    end
  end
end
