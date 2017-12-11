defmodule CodeCorpsWeb.MessageController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Helpers.Query,
    Message,
    Messages,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with messages <- Message |> Query.id_filter(params) |> Repo.all() do
      conn |> render("index.json-api", data: messages)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      %Message{} = message <- Message |> Repo.get(id),
      {:ok, :authorized} <- current_user |> Policy.authorize(:show, message, %{}) do
      conn |> render("show.json-api", data: message)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Message{}, params),
         {:ok, %Message{} = message} <- Messages.create(params),
         message <- preload(message)
    do
      conn |> put_status(:created) |> render("show.json-api", data: message)
    end
  end

  @preloads [:author, :project]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
