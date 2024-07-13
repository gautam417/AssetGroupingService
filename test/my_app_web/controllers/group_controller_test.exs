defmodule MyAppWeb.GroupControllerTest do
  use MyAppWeb.ConnCase
  alias MyAppWeb.GroupController

  describe "GroupController" do
    setup do
      :ok
    end

    test "POST /api/groups creates a new group", %{conn: conn} do
      group_params = %{"name" => "TestGroup", "rules" => [{"field" => "type", "operator" => "==", "value" => "document"}]}

      conn = post(conn, Routes.group_path(conn, :create), group_params)
      assert conn.status == 201
      assert json_response(conn, 201)["status"] == "success"
      assert json_response(conn, 201)["group"]["name"] == "TestGroup"
    end

    test "GET /api/groups/:id/assets retrieves assets belonging to a group", %{conn: conn} do
      group_id = "valid_group_id"

      conn = get(conn, Routes.group_path(conn, :get_assets, group_id))
      assert conn.status == 200
      assert json_response(conn, 200)["status"] == "success"
    end

    test "GET /api/groups/:id/assets returns not found for non-existent group", %{conn: conn} do
      group_id = "non_existent_group_id"

      conn = get(conn, Routes.group_path(conn, :get_assets, group_id))
      assert conn.status == 404
      assert json_response(conn, 404)["status"] == "error"
      assert json_response(conn, 404)["message"] == "Group not found"
    end
  end
end
