defmodule CodeCorpsWeb.TaskView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JSONAPI.View, type: "task"

  alias CodeCorpsWeb.{GithubIssueView, GithubPullRequestView, GithubRepoView, ProjectView,
    TaskListView, UserView, UserTaskView, CommentView, TaskSkillView}

  def fields do
    [:archived, :body, :created_at, :created_from, :inserted_at, :markdown,
    :modified_at, :modified_from, :number, :order, :status, :title, :updated_at]
  end

  def relationships do
    [github_issue: GithubIssueView, github_pull_request: GithubPullRequestView,
      github_repo: GithubRepoView, project: ProjectView, task_list: TaskListView,
      user: UserView, user_task: UserTaskView, comments: CommentView, task_skills: TaskSkillView]
  end

end
