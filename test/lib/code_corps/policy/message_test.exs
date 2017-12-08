defmodule CodeCorps.Policy.MessageTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Message, only: [create?: 2, index?: 3, show?: 2]

  defp params_for(initiated_by, project_id, author_id) do
    %{
      "initiated_by" => initiated_by,
      "author_id" => author_id,
      "project_id" => project_id
    }
  end

  describe "index?" do
    test "returns true when empty list" do
      user = insert(:user)

      assert index?(user, [], %{})
    end

    test "returns true when user is author of all the messages" do
      author = insert(:user)
      messages = insert_list(2, :message, initiated_by: "user", author: author)

      assert index?(author, messages, %{})
    end

    test "returns false when user is not author of all the messages" do
      author = insert(:user)
      message1 = insert(:message, author: author)
      message2 = insert(:message)

      refute index?(author, [message1, message2], %{})
    end

    test "returns true when initiated by user and user is the author" do
      author = insert(:user)
      params = %{"author_id" => author.id}

      assert index?(author, [], params)
    end

    test "returns false when initiated by user and user is not the author" do
      user = insert(:user)
      params = %{"author_id" => "-1"}

      refute index?(user, [], params)
    end

    test "returns false when filtering project and user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      params = %{"project_id" => project.id}

      refute index?(user, [], params)
    end

    test "returns false when filtering project and user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      params = %{"project_id" => project.id}

      refute index?(user, [], params)
    end

    test "returns true when filtering project and user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      params = %{"project_id" => project.id}

      assert index?(user, [], params)
    end

    test "returns true when filtering project and user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      params = %{"project_id" => project.id}

      assert index?(user, [], params)
    end

    test "returns false when messages for project and user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, project: project)

      refute index?(user, [message], %{})
    end

    test "returns false when messages for project and user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, project: project)

      refute index?(user, [message], %{})
    end

    test "returns false when messages not for project and user is a project admin" do
      %{project: _project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message)

      refute index?(user, [message], %{})
    end

    test "returns true when messages for project and user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, project: project)

      assert index?(user, [message], %{})
    end

    test "returns true when messages for project and user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, project: project)

      assert index?(user, [message], %{})
    end
  end

  describe "show?" do
    test "returns true when initiated by user and user is the author" do
      author = insert(:user)
      message = insert(:message, initiated_by: "user", author: author)

      assert show?(author, message)
    end

    test "returns false when initiated by user and user is not the author" do
      user = insert(:user)
      message = insert(:message, initiated_by: "user")

      refute show?(user, message)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, initiated_by: "user", project: project)

      refute show?(user, message)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, initiated_by: "user", project: project)

      refute show?(user, message)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, initiated_by: "user", project: project)

      assert show?(user, message)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, initiated_by: "user", project: project)

      assert show?(user, message)
    end
  end

  describe "create?" do
    test "returns true when initiated by user and user is the author" do
      author = insert(:user)
      params = params_for("user", 1, author.id)

      assert create?(author, params)
    end

    test "returns false when initiated by user and user is not the author" do
      user = insert(:user)
      params = params_for("user", 1, -1)

      refute create?(user, params)
    end

    test "returns false when initiated by admin and user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      refute create?(user, params)
    end

    test "returns false when initiated by admin and user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      refute create?(user, params)
    end

    test "returns true when initiated by admin and user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      assert create?(user, params)
    end

    test "returns true when initiated by admin and user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      assert create?(user, params)
    end
  end
end
