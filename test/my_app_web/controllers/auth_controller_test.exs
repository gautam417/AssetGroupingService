defmodule MyAppWeb.AuthControllerTest do
  use MyAppWeb.ConnCase
  alias MyAppWeb.AuthController

  describe "AuthController" do
    setup do
      :ok
    end

    test "POST /api/login returns token on successful authentication", %{conn: conn} do
      username = "admin"
      password = "secret"

      conn = post(conn, Routes.auth_path(conn, :login), %{username: username, password: password})
      assert json_response(conn, 200)["token"]
    end

    test "POST /api/login returns unauthorized on failed authentication", %{conn: conn} do
      username = "invalid_user"
      password = "invalid_password"

      conn = post(conn, Routes.auth_path(conn, :login), %{username: username, password: password})
      assert conn.status == 401
      assert json_response(conn, 401)["error"] == "Unauthorized"
    end
  end
end
