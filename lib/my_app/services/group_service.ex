defmodule MyApp.GroupService do
  alias MyApp.{Group, Repo, Asset, AssetService}
  import Ecto.Query

  require Logger

  def create_group(%{"name" => name, "rules" => rules} = attrs) do
    Logger.info("Creating group with attrs: #{inspect(attrs)}")

    encoded_rules = Jason.encode!(rules)
    changeset = Group.changeset(%Group{}, %{"name" => name, "rules" => encoded_rules})
    Logger.info("Changeset after creation: #{inspect(changeset)}")

    if changeset.valid? do
      Repo.insert(changeset)
    else
      {:error, changeset}
    end
  end

  def update_group(id, attrs \\ %{}) do
    Logger.info("Updating group with id: #{id} and attrs: #{inspect(attrs)}")
    group = Repo.get!(Group, id)
    changeset = Group.changeset(group, attrs)
    Logger.info("Update changeset: #{inspect(changeset)}")
    if changeset.valid? do
      Repo.update(changeset)
    else
      Logger.error("Invalid update changeset: #{inspect(changeset)}")
      {:error, changeset}
    end
  end

  def get_assets_by_group(id) do
    Logger.info("Getting assets by group id: #{id}")
    with {:ok, group} <- fetch_group(id),
        {:ok, rules} <- decode_rules(group.rules) do
          case apply_grouping_rules(rules) do
            {:ok, assets} ->
              {:ok, assets}
            {:error, reason} ->
              {:error, reason}
          end
        else
          {:error, reason} ->
            Logger.error("Failed to get assets by group #{id}: #{reason}")
            {:error, reason}
      end
  end

  defp decode_rules(rules) do
    Logger.info("Raw rules string: #{inspect(rules)}")

    case Jason.decode(rules) do
      {:ok, decoded_rules} ->
        Logger.info("Decoded rules: #{inspect(decoded_rules)}")
        {:ok, decoded_rules}
      {:error, reason} ->
        Logger.error("Failed to decode rules: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp fetch_group(id) do
    case Repo.get(Group, id) do
      nil -> {:error, "Group not found"}
      group -> {:ok, group}
    end
  end

  def apply_grouping_rules(rules) do
    Logger.info("Applying grouping rules: #{inspect(rules)}")
    case build_conditions(rules) do
      {:ok, conditions} ->
        Logger.info("Built conditions: #{inspect(conditions)}")
        query = from a in Asset, where: ^conditions
        assets = Repo.all(query)
        Logger.info("Fetched assets: #{inspect(assets)}")
        {:ok, assets}
      {:error, reason} ->
        Logger.error("Failed to apply grouping rules: #{reason}")
        {:error, reason}
    end
  end

  def build_conditions(rules) do
    Logger.info("Building conditions from rules: #{inspect(rules)}")

    cleaned_rules = String.replace(rules, ~r/\\\"/, "\"")
    case Jason.decode(cleaned_rules) do
      {:ok, decoded_rules} ->
        Enum.reduce_while(decoded_rules, true, fn rule, acc ->
          case build_condition(rule) do
            {:ok, condition} ->
              Logger.info("Built condition: #{inspect(condition)}")
              {:cont, {:ok, Ecto.Query.dynamic([a], ^acc and ^condition)}}
            {:error, reason} ->
              Logger.error("Failed to build condition for rule #{inspect(rule)}: #{reason}")
              {:halt, {:error, reason}}
          end
        end)
    end
  end

  defp build_condition(%{"field" => field, "operator" => operator, "value" => value}) do
    Logger.info("Building condition for  field: #{field}, operator: #{operator}, value: #{value}")

    case operator do
      "==" -> {:ok, Ecto.Query.dynamic([a], field(a, ^String.to_atom(field)) == ^value)}
      "!=" -> {:ok, Ecto.Query.dynamic([a], field(a, ^String.to_atom(field)) != ^value)}
      _ -> {:error, "Invalid operator: #{operator}"}
    end
  end
end
