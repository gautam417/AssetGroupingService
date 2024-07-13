defmodule MyApp.Group do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  @derive {Jason.Encoder, only: [:id, :name, :rules, :inserted_at, :updated_at]}
  schema "groups" do
    field :name, :string
    field :rules, :string

    timestamps()
  end

  def changeset(group, %{"name" => name, "rules" => rules} = attrs) do
    Logger.info("Changeset received attrs: #{inspect(attrs)}")
    group
      |> cast(%{"name" => name, "rules" => Jason.encode!(rules)}, [:name, :rules])
      |> validate_required([:name])
  end

  defp encode_rules(changeset) do
    rules = get_field(changeset, :rules)
    Logger.info("Rules before encoding: #{inspect(rules)}")

    if is_list(rules) or is_map(rules) do
      put_change(changeset, :rules, Jason.encode!(rules))
    else
      changeset
    end
  end
end
