defmodule Todolist.UsersTest do
  use Todolist.DataCase

  alias Todolist.Users

  describe "users" do
    alias Todolist.Users.User

    import Todolist.UsersFixtures

    @invalid_attrs %{address: nil, role: nil, mail: nil, firstname: nil, lastname: nil, team_id: nil, phone: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{address: "some address", role: "some role", mail: "some mail", firstname: "some firstname", lastname: "some lastname", team_id: 42, phone: "some phone"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.address == "some address"
      assert user.role == "some role"
      assert user.mail == "some mail"
      assert user.firstname == "some firstname"
      assert user.lastname == "some lastname"
      assert user.team_id == 42
      assert user.phone == "some phone"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{address: "some updated address", role: "some updated role", mail: "some updated mail", firstname: "some updated firstname", lastname: "some updated lastname", team_id: 43, phone: "some updated phone"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.address == "some updated address"
      assert user.role == "some updated role"
      assert user.mail == "some updated mail"
      assert user.firstname == "some updated firstname"
      assert user.lastname == "some updated lastname"
      assert user.team_id == 43
      assert user.phone == "some updated phone"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
