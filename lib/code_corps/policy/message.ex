defmodule CodeCorps.Policy.Message do
  @moduledoc """
  Handles `User` authorization of actions on `Message` records
  """

  import CodeCorps.Policy.Helpers, only: [administered_by?: 2, get_project: 1]

  alias CodeCorps.{Message, User}

  def index?(%User{id: id}, _messages, %{"author_id" => author_id}) do
    id === author_id
  end
  def index?(%User{} = user, _messages, %{"project_id" => _} = params) do
    params |> get_project() |> administered_by?(user)
  end
  def index?(_, [], _), do: true
  def index?(%User{} = user, messages, _params) do
    messages |> Enum.map(&show?(user, &1)) |> Enum.any?()
  end
  def index?(_, _, _), do: false

  def show?(%User{id: user_id}, %{initiated_by: "user", author_id: author_id})
    when user_id == author_id do
    true
  end
  def show?(%User{} = user, %Message{} = message) do
    message |> get_project() |> administered_by?(user)
  end
  def show?(_, _), do: false

  def create?(%User{id: id}, %{"initiated_by" => "user", "author_id" => author_id}) when id === author_id do
    true
  end
  def create?(%User{} = user, %{"initiated_by" => "admin", "project_id" => _} = params) do
    params |> get_project() |> administered_by?(user)
  end
  def create?(_, _), do: false
end
