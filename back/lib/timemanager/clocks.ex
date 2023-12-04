defmodule Todolist.Clocks do
  @moduledoc """
  The Clocks context.
  """

  import Ecto.Query, warn: false
  alias Todolist.Repo
  alias Todolist.Clocks.Clock

  import Ecto.Query, warn: false

  @doc """
  Returns the list of clocks.

  ## Examples

      iex> list_clocks()
      [%Clock{}, ...]

  """
  def list_clocks do
    Repo.all(Clock)
  end

  @doc """
  Gets a single clock.

  Raises `Ecto.NoResultsError` if the Clock does not exist.

  ## Examples

      iex> get_clock!(123)
      %Clock{}

      iex> get_clock!(456)
      ** (Ecto.NoResultsError)

  """
  def get_clock!(id), do: Repo.get!(Clock, id)

  @doc """
  Creates a clock.

  ## Examples

      iex> create_clock(%{field: value})
      {:ok, %Clock{}}

      iex> create_clock(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_clock(attrs \\ %{}) do
    %Clock{}
    |> Clock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a clock.

  ## Examples

      iex> update_clock(clock, %{field: new_value})
      {:ok, %Clock{}}

      iex> update_clock(clock, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_clock(%Clock{} = clock, attrs) do
    clock
    |> Clock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a clock.

  ## Examples

      iex> delete_clock(clock)
      {:ok, %Clock{}}

      iex> delete_clock(clock)
      {:error, %Ecto.Changeset{}}

  """
  def delete_clock(%Clock{} = clock) do
    Repo.delete(clock)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking clock changes.

  ## Examples

      iex> change_clock(clock)
      %Ecto.Changeset{data: %Clock{}}

  """
  def change_clock(%Clock{} = clock, attrs \\ %{}) do
    Clock.changeset(clock, attrs)
  end

  def is_clocked_in?(user_id) do
    clock = Repo.one(from(c in Clock, where: c.user_id == ^user_id and c.status == true))
    !is_nil(clock)
  end

  def clock_in(user_id) do
    %Clock{user_id: user_id, time: DateTime.truncate(DateTime.utc_now(), :second), status: true}
    |> Repo.insert!()
  end

  def clock_out(user_id) do
    clock = Repo.one(from(c in Clock, where: c.user_id == ^user_id and c.status == true))

    if clock do
      clock_out_time = DateTime.utc_now()
      time_spent = NaiveDateTime.diff(clock_out_time, clock.time)

      Repo.update_all(
        from(c in Clock, where: c.user_id == ^user_id and c.status == true),
        set: [status: false, time: clock_out_time]
      )

      {:ok, %{message: "Clock-out successful", time_spent: time_spent}}
    else
      {:error, "Clock-out failed: No active clock-in found for the user"}
    end
  end
end
