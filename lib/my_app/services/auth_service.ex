defmodule MyApp.AuthService do
  alias MyApp.TokenManagement

  @spec authenticate(String.t(), String.t()) :: {:ok, String.t()} | {:error, :unauthorized}
  def authenticate(username, password) do
    if username == "admin" and password == "secret" do
      {:ok, TokenManagement.generate_token(username)}
    else
      {:error, :unauthorized}
    end
  end
end
