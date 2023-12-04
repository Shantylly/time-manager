defmodule TodolistWeb.TimespentControllerTest do
  use TodolistWeb.ConnCase

  import Todolist.TimespentsFixtures

  alias Todolist.Timespents.Timespent

  @create_attrs %{
    description: "some description",
    date_start: "some date_start",
    date_end: "some date_end",
    user_id: 42
  }
  @update_attrs %{
    description: "some updated description",
    date_start: "some updated date_start",
    date_end: "some updated date_end",
    user_id: 43
  }
  @invalid_attrs %{description: nil, date_start: nil, date_end: nil, user_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all timespents", %{conn: conn} do
      conn = get(conn, ~p"/api/timespents")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create timespent" do
    test "renders timespent when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/timespents", timespent: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/timespents/#{id}")

      assert %{
               "id" => ^id,
               "date_end" => "some date_end",
               "date_start" => "some date_start",
               "description" => "some description",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/timespents", timespent: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update timespent" do
    setup [:create_timespent]

    test "renders timespent when data is valid", %{conn: conn, timespent: %Timespent{id: id} = timespent} do
      conn = put(conn, ~p"/api/timespents/#{timespent}", timespent: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/timespents/#{id}")

      assert %{
               "id" => ^id,
               "date_end" => "some updated date_end",
               "date_start" => "some updated date_start",
               "description" => "some updated description",
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, timespent: timespent} do
      conn = put(conn, ~p"/api/timespents/#{timespent}", timespent: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete timespent" do
    setup [:create_timespent]

    test "deletes chosen timespent", %{conn: conn, timespent: timespent} do
      conn = delete(conn, ~p"/api/timespents/#{timespent}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/timespents/#{timespent}")
      end
    end
  end

  defp create_timespent(_) do
    timespent = timespent_fixture()
    %{timespent: timespent}
  end
end
