defmodule CodeCorps.Policy.Message do
  @moduledoc """
  Handles `User` authorization of actions on `Message` records
  """

  import CodeCorps.Policy.Helpers, only: [administered_by?: 2, get_project: 1]
  import Ecto.Query

  alias CodeCorps.{Message, Project, ProjectUser, User, Repo}

  @spec scope(Ecto.Queryable.t, User.t) :: Ecto.Queryable.t
  def scope(queryable, %User{admin: true}), do: queryable
  def scope(queryable, %User{id: id}) do
    projects_administered_by_user_query =
      from p in Project,
        join: pu in ProjectUser, on: pu.project_id == p.id,
        where: pu.user_id == ^id,
        where: pu.role in ~w(admin owner)

    projects_administered_by_user_ids =
      from(p in projects_administered_by_user_query, select: p.id)
      |> Repo.all

    queryable
    |> where([m], m.author_id == ^id)
    |> or_where([m], m.project_id in ^projects_administered_by_user_ids)
  end

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
