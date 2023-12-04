defmodule Todolist.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todolist.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        address: "some address",
        firstname: "some firstname",
        lastname: "some lastname",
        mail: "some mail",
        phone: "some phone",
        role: "some role",
        team_id: 42
      })
      |> Todolist.Users.create_user()

    user
  end
end
