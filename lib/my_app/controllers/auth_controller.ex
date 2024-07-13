defmodule MyAppWeb.AuthController do
  use MyAppWeb, :controller

  alias MyApp.AuthService

  def login(conn, %{"username" => username, "password" => password}) do
    case AuthService.authenticate(username, password) do
      {:ok, token} ->
        json(conn, %{token: token})

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
    end
  end
end
