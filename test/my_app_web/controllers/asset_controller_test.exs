defmodule MyAppWeb.AssetControllerTest do
  use MyAppWeb.ConnCase
  alias MyAppWeb.AssetController
  alias MyApp.AssetService
  alias MyApp.Asset

  describe "AssetController" do
    setup [:create_test_assets]

    def create_test_assets(_context) do
      {:ok, asset1} = AssetService.create_asset(%{name: "Asset1", type: "document"})
      {:ok, asset2} = AssetService.create_asset(%{name: "Asset2", type: "image"})
      {:ok, asset3} = AssetService.create_asset(%{name: "Asset3", type: "document"})

      {:ok, %{asset1: asset1, asset2: asset2, asset3: asset3}}
    end

    test "POST /api/assets creates a new asset", %{conn: conn} do
      asset_params = %{name: "New Asset", type: "document"}

      conn = post(conn, Routes.asset_path(conn, :create), asset_params)
      assert conn.status == 201
      assert json_response(conn, 201)["status"] == "success"
      assert json_response(conn, 201)["asset"]["name"] == "New Asset"
    end

    test "GET /api/assets/:id retrieves an asset by ID", %{conn: conn, asset1: asset1} do
      conn = get(conn, Routes.asset_path(conn, :show, asset1.id))
      assert conn.status == 200
      assert json_response(conn, 200)["status"] == "success"
      assert json_response(conn, 200)["asset"]["name"] == "Asset1"
    end

    test "GET /api/assets/:id returns not found for non-existent asset", %{conn: conn} do
      conn = get(conn, Routes.asset_path(conn, :show, "non_existent_id"))
      assert conn.status == 404
      assert json_response(conn, 404)["status"] == "error"
      assert json_response(conn, 404)["message"] == "Asset not found"
    end

    test "DELETE /api/assets/:id deletes an asset by ID", %{conn: conn, asset2: asset2} do
      conn = delete(conn, Routes.asset_path(conn, :delete, asset2.id))
      assert conn.status == 200
      assert json_response(conn, 200)["message"] == "Asset deleted successfully"
    end

    test "GET /api/assets lists all assets", %{conn: conn} do
      conn = get(conn, Routes.asset_path(conn, :index))
      assert conn.status == 200
      assert length(json_response(conn, 200)["assets"]) == 3
    end

    test "POST /api/assets/search searches assets based on criteria", %{conn: conn} do
      search_criteria = %{"criteria" => [%{"field" => "type", "operator" => "==", "value" => "document"}]}

      conn = post(conn, Routes.asset_path(conn, :search), search_criteria)
      assert conn.status == 200
      assert length(json_response(conn, 200)["assets"]) == 2
      assert Enum.all?(json_response(conn, 200)["assets"], fn asset -> asset["type"] == "document" end)
    end
  end

  defp json_response(conn, status) do
    conn
    |> get_resp_content_type()
    |> case do
      "application/json; charset=utf-8" ->
        conn
        |> json_response(status)
      _ ->
        raise "expected content type application/json; charset=utf-8, got #{inspect(conn.resp_headers)}"
    end
  end
end
