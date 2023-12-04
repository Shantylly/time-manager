defmodule TodolistWeb.UserJSON do
  alias Todolist.Users.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      firstname: user.firstname,
      lastname: user.lastname,
      role: user.role,
      team_id: user.team_id,
      address: user.address,
      mail: user.mail,
      phone: user.phone,
      password: user.password,
      genre: user.genre,
    }
  end
end
