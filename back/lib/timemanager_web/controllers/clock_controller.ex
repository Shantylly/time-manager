defmodule TodolistWeb.ClockController do
  alias Todolist.Clocks

  use TodolistWeb, :controller

  action_fallback TodolistWeb.FallbackController

  def clock_in(conn, %{"user_id" => user_id}) do
    if Clocks.is_clocked_in?(String.to_integer(user_id)) do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "User has already clocked in"})
    else
      Clocks.clock_in(String.to_integer(user_id))
      conn
      |> put_status(:ok)
      |> json(%{message: "Clock-in successful", time: DateTime.utc_now()})
    end
  end

  def is_clocked_in(conn, %{"user_id" => user_id}) do
    if Clocks.is_clocked_in?(String.to_integer(user_id)) do
      conn
      |> put_status(:ok)
      |> json(%{message: "User has already clocked in", status: true})
    else
      conn
      |> put_status(:ok)
      |> json(%{message: "User is not clocked in", status: false})
    end
  end

  def clock_out(conn, %{"user_id" => user_id}) do
    case Clocks.clock_out(String.to_integer(user_id)) do
      {:ok, %{message: message, time_spent: time_spent}} ->
        conn
        |> put_status(:ok)
        |> json(%{message: message, time_spent: time_spent})
      {:error, error_message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: error_message})
    end
  end
end
