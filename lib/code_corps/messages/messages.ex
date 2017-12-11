defmodule CodeCorps.Messages do
  @moduledoc ~S"""
  Main context for work with the Messaging feature.
  """

  alias CodeCorps.{Helpers.Query, Message, Messages, Repo}
  alias Ecto.{Changeset}

  @doc ~S"""
  Lists `CodeCorps.Message` filtered by parameters.
  """
  @spec list(map) :: list(Message.t)
  def list(%{} = params) do
    Message
    |> Query.id_filter(params)
    |> Messages.Query.author_filter(params)
    |> Messages.Query.project_filter(params)
    |> Repo.all()
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
