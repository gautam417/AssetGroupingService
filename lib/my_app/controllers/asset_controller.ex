defmodule MyAppWeb.AssetController do
  use MyAppWeb, :controller
  alias MyApp.AssetService
  import Phoenix.Controller

  def create(conn, asset_params) do
    case AssetService.create_asset(asset_params) do
      {:ok, asset} ->
        conn
        |> put_status(:created)
        |> json_response(%{status: "success", asset: asset})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: changeset.errors})
    end
  end

  def show(conn, %{"id" => id}) do
    case AssetService.get_asset(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Asset not found"})

      asset ->
        conn
        |> json(%{status: "success", asset: asset})
    end
  end

  def delete(conn, %{"id" => id}) do
    case MyApp.AssetService.delete_asset(id) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> json(%{message: message})
      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})
    end
  end

  def index(conn, _params) do
    assets = AssetService.list_assets()
    conn
    |> put_status(:ok)
    |> json(%{status: "success", assets: assets})
  end

  def search(conn, %{"criteria" => criteria}) do
    case AssetService.search_assets(criteria) do
      {:ok, assets} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "success", assets: assets})

      {:error, :bad_request} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", message: "Bad request"})
    end
  end

  defp json_response(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(data))
  end
end
