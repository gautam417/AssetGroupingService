defmodule MyAppWeb.Plugs.Authenticate do
  import Plug.Conn
  alias MyApp.TokenManagement

  def init(default), do: default

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case TokenManagement.verify_token(token) do
          {:ok, username} ->
            assign(conn, :current_user, username)
          {:error, _reason} -> unauthorized_response(conn)
        end

      _ ->
        if conn.request_path != "/api/login" do
          unauthorized_response(conn)
        else
          conn
        end
    end
  end

  def unauthorized_response(conn) do
    conn
    |> put_status(:unauthorized)
    |> halt()
  end
end
