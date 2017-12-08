defmodule CodeCorps.Messages do
  @moduledoc ~S"""
  """

  import Ecto.Query, only: [where: 3]

  alias CodeCorps.{Helpers.Query, Message, Repo}
  alias Ecto.{Changeset}

  @doc ~S"""
  Lists `CodeCorps.Message` filtered by parameters.
  """
  def list(%{"author_id" => author_id}) do
    Message
    |> where([m], m.author_id == ^author_id)
    |> Repo.all()
  end

  def list(%{"project_id" => project_id}) do
    Message
    |> where([m], m.project_id == ^project_id)
    |> Repo.all()
  end

  def list(%{} = params) do
    Message |> Query.id_filter(params) |> Repo.all()
  end

  @doc ~S"""
  Creates a `CodeCorps.Message` from a set of parameters.
  """
  @spec create(map) :: {:ok, Message.t} | {:error, Changeset.t}
  def create(%{} = params) do
    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
  end
end
