defmodule Todolist.TimespentsTest do
  use Todolist.DataCase

  alias Todolist.Timespents

  describe "timespents" do
    alias Todolist.Timespents.Timespent

    import Todolist.TimespentsFixtures

    @invalid_attrs %{description: nil, date_start: nil, date_end: nil, user_id: nil}

    test "list_timespents/0 returns all timespents" do
      timespent = timespent_fixture()
      assert Timespents.list_timespents() == [timespent]
    end

    test "get_timespent!/1 returns the timespent with given id" do
      timespent = timespent_fixture()
      assert Timespents.get_timespent!(timespent.id) == timespent
    end

    test "create_timespent/1 with valid data creates a timespent" do
      valid_attrs = %{description: "some description", date_start: "some date_start", date_end: "some date_end", user_id: 42}

      assert {:ok, %Timespent{} = timespent} = Timespents.create_timespent(valid_attrs)
      assert timespent.description == "some description"
      assert timespent.date_start == "some date_start"
      assert timespent.date_end == "some date_end"
      assert timespent.user_id == 42
    end

    test "create_timespent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timespents.create_timespent(@invalid_attrs)
    end

    test "update_timespent/2 with valid data updates the timespent" do
      timespent = timespent_fixture()
      update_attrs = %{description: "some updated description", date_start: "some updated date_start", date_end: "some updated date_end", user_id: 43}

      assert {:ok, %Timespent{} = timespent} = Timespents.update_timespent(timespent, update_attrs)
      assert timespent.description == "some updated description"
      assert timespent.date_start == "some updated date_start"
      assert timespent.date_end == "some updated date_end"
      assert timespent.user_id == 43
    end

    test "update_timespent/2 with invalid data returns error changeset" do
      timespent = timespent_fixture()
      assert {:error, %Ecto.Changeset{}} = Timespents.update_timespent(timespent, @invalid_attrs)
      assert timespent == Timespents.get_timespent!(timespent.id)
    end

    test "delete_timespent/1 deletes the timespent" do
      timespent = timespent_fixture()
      assert {:ok, %Timespent{}} = Timespents.delete_timespent(timespent)
      assert_raise Ecto.NoResultsError, fn -> Timespents.get_timespent!(timespent.id) end
    end

    test "change_timespent/1 returns a timespent changeset" do
      timespent = timespent_fixture()
      assert %Ecto.Changeset{} = Timespents.change_timespent(timespent)
    end
  end
end
