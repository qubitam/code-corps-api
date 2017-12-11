defmodule CodeCorps.MessagesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.Messages

  describe "list" do
    defp get_and_sort_ids(records) do
      records |> Enum.map(&Map.get(&1, :id)) |> Enum.sort
    end

    test "returns all records by default" do
      insert_list(3, :message)
      assert Messages.list(%{}) |> Enum.count == 3
    end

    test "can filter by project" do
      [project_1, project_2] = insert_pair(:project)
      messages_from_project_1 = insert_pair(:message, project: project_1)
      message_from_project_2 = insert(:message, project: project_2)

      results = Messages.list(%{"project_id" => project_1.id})
      assert results |> Enum.count == 2
      assert results |> get_and_sort_ids() ==
        messages_from_project_1 |> get_and_sort_ids()

      results = Messages.list(%{"project_id" => project_2.id})
      assert results |> Enum.count == 1
      assert results |> get_and_sort_ids() ==
        [message_from_project_2.id]
    end

    test "can filter by author" do
      [author_1, author_2] = insert_pair(:user)
      messages_from_author_1 = insert_pair(:message, author: author_1)
      message_from_author_2 = insert(:message, author: author_2)

      results = Messages.list(%{"author_id" => author_1.id})
      assert results |> Enum.count == 2
      assert results |> get_and_sort_ids() ==
        messages_from_author_1 |> get_and_sort_ids()

      results = Messages.list(%{"author_id" => author_2.id})
      assert results |> Enum.count == 1
      assert results |> get_and_sort_ids() ==
        [message_from_author_2.id]
    end

    test "can filter by list of ids" do
      [message_1, message_2, message_3] = insert_list(3, :message)

      results =
        %{"filter" => %{"id" => "#{message_1.id},#{message_3.id}"}}
        |> Messages.list
      assert results |> Enum.count == 2
      assert results |> get_and_sort_ids() ==
        [message_1, message_3] |> get_and_sort_ids()

      results =
        %{"filter" => %{"id" => "#{message_2.id}"}} |> Messages.list
      assert results |> Enum.count == 1
      assert results |> get_and_sort_ids() ==
        [message_2] |> get_and_sort_ids()
    end

    test "can apply multiple filters at once" do
      [project_1, project_2] = insert_pair(:project)
      [author_1, author_2] = insert_pair(:user)

      message_p1_a1 = insert(:message, project: project_1, author: author_1)
      message_p1_a2 = insert(:message, project: project_1, author: author_2)
      message_p2_a1 = insert(:message, project: project_2, author: author_1)
      message_p2_a2 = insert(:message, project: project_2, author: author_2)

      results =
        %{"project_id" => project_1.id, "author_id" => author_1.id}
        |> Messages.list
      assert results |> get_and_sort_ids() == [message_p1_a1.id]

      results =
        %{"project_id" => project_1.id, "author_id" => author_2.id}
        |> Messages.list
      assert results |> get_and_sort_ids() == [message_p1_a2.id]

      results =
        %{"project_id" => project_2.id, "author_id" => author_1.id}
        |> Messages.list
      assert results |> get_and_sort_ids() == [message_p2_a1.id]

      results =
        %{"project_id" => project_2.id, "author_id" => author_2.id}
        |> Messages.list
      assert results |> get_and_sort_ids() == [message_p2_a2.id]

      results =
        %{
          "filter" => %{"id" => "#{message_p1_a1.id},#{message_p2_a1.id}"},
          "project_id" => project_1.id
        } |> Messages.list

      assert results |> get_and_sort_ids() == [message_p1_a1.id]
    end
  end
end
