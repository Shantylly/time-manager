defmodule TodolistWeb.TimespentController do
  use TodolistWeb, :controller

  alias Todolist.Timespents
  alias Todolist.Timespents.Timespent

  action_fallback TodolistWeb.FallbackController

  def index(conn, _params) do
    timespents = Timespents.list_timespents()
    render(conn, :index, timespents: timespents)
  end

  def create(conn, %{"description" => description,"date_start" => date_start,"date_end" => date_end,"user_id" => user_id}) do
    timespent_params = %{
      description: description,
      date_start: date_start,
      date_end: date_end,
      user_id: user_id
    }
    with {:ok, %Timespent{} = timespent} <- Timespents.create_timespent(timespent_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/timespents/#{timespent}")
      |> render(:show, timespent: timespent)
    end
  end



  def show(conn, %{"id" => id}) do
    timespent = Timespents.get_timespent!(id)
    render(conn, :show, timespent: timespent)
  end

  def update(conn, %{"id" => id} = timespent_params) do
    timespent = Timespents.get_timespent!(id)

    with {:ok, %Timespent{} = timespent} <- Timespents.update_timespent(timespent, timespent_params) do
      render(conn, :show, timespent: timespent)
    end
  end

  def delete(conn, %{"id" => id}) do
    timespent = Timespents.get_timespent!(id)

    with {:ok, %Timespent{}} <- Timespents.delete_timespent(timespent) do
      send_resp(conn, :no_content, "")
    end
  end

  @spec list_timespents_by_user(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def list_timespents_by_user(conn, %{"user_id" => user_id}) do
    timespents = Timespents.list_timespents_by_user(user_id)

    conn
    |> put_status(:ok)
    |> json(%{timespents: timespents})
  end
end
