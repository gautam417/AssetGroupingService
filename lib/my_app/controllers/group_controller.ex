defmodule MyAppWeb.GroupController do
  use MyAppWeb, :controller
  alias MyApp.GroupService
  import Phoenix.Controller
  require Logger


  def create(conn, %{"name" => name, "rules" => rules}) do
    case GroupService.create_group(%{"name" => name, "rules" => rules}) do
      {:ok, group} ->
        conn
        |> put_status(:created)
        |> json_response(%{status: "success", group: group})
      {:error, changeset} ->
        Logger.error("Failed to create group: #{inspect(changeset.errors)}")
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: changeset.errors})
    end
  end

  defp json_response(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(data))
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    case GroupService.update_group(id, group_params) do
      {:ok, group} ->
        conn
        |> json(%{status: "success", group: group})

      {:error, changeset} ->
        Logger.error("Failed to update group: #{inspect(changeset)}")
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: changeset.errors})
    end
  end

  def get_assets(conn, %{"id" => id}) do
    case GroupService.get_assets_by_group(id) do
      {:ok, assets} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "success", asset: assets})
      {:error, :not_found} ->
        Logger.error("Failed to fetch assets by group")
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Group not found"})
    end
  end

  def convert_to_encodable(asset) do
    %{id: asset.id,
    name: asset.name,
    rules: Jason.decode!(asset.rules),
    inserted_at: asset.inserted_at,
    updated_at: asset.updated_at}
  end
end
