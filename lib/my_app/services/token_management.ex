defmodule MyApp.TokenManagement do
  alias MyApp.Token

  def generate_token(username) do
    {:ok, token, _claims} = Token.generate_and_sign(%{"username" => username})
    token
  end

  def verify_token(token) do
    case Token.verify_and_validate(token) do
      {:ok, claims} -> {:ok, claims["username"]}
      {:error, _reason} -> {:error, :unauthorized}
    end
  end
end
