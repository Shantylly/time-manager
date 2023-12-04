defmodule Todolist.Timespents do
  @moduledoc """
  The Timespents context.
  """

  import Ecto.Query, warn: false
  alias Todolist.Repo

  alias Todolist.Timespents.Timespent

  @doc """
  Returns the list of timespents.

  ## Examples

      iex> list_timespents()
      [%Timespent{}, ...]

  """
  def list_timespents do
    Repo.all(Timespent)
  end

  def list_timespents_by_user(user_id) do
    from(t in Todolist.Timespents.Timespent)
    |> where([t], t.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single timespent.

  Raises `Ecto.NoResultsError` if the Timespent does not exist.

  ## Examples

      iex> get_timespent!(123)
      %Timespent{}

      iex> get_timespent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timespent!(id), do: Repo.get!(Timespent, id)

  @doc """
  Creates a timespent.

  ## Examples

      iex> create_timespent(%{field: value})
      {:ok, %Timespent{}}

      iex> create_timespent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timespent(attrs \\ %{}) do
    %Timespent{}
    |> Timespent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timespent.

  ## Examples

      iex> update_timespent(timespent, %{field: new_value})
      {:ok, %Timespent{}}

      iex> update_timespent(timespent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timespent(%Timespent{} = timespent, attrs) do
    timespent
    |> Timespent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timespent.

  ## Examples

      iex> delete_timespent(timespent)
      {:ok, %Timespent{}}

      iex> delete_timespent(timespent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timespent(%Timespent{} = timespent) do
    Repo.delete(timespent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timespent changes.

  ## Examples

      iex> change_timespent(timespent)
      %Ecto.Changeset{data: %Timespent{}}

  """
  def change_timespent(%Timespent{} = timespent, attrs \\ %{}) do
    Timespent.changeset(timespent, attrs)
  end
end
