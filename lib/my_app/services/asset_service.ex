defmodule MyApp.AssetService do
  alias MyApp.{Asset, Repo, AssetQueries, Group}

  import Ecto.Query

  def create_asset(attrs \\ %{}) do
    %Asset{}
    |> Asset.changeset(attrs)
    |> Repo.insert()
  end

  def get_asset(id), do: Repo.get(Asset, id)

  def delete_asset(id) do
    case Repo.get(Asset, id) do
      nil ->
        {:error, "Asset not found"}
      asset ->
        Repo.delete!(asset)
        {:ok, "Asset deleted successfully"}
    end
  rescue
    Ecto.NoResultsError -> {:error, "Asset not found"}
  end

  def list_assets(), do: Repo.all(Asset)

  def search_assets(criteria) do
    case build_query(criteria) do
      {:ok, query} ->
        assets = Repo.all(query)
        {:ok, assets}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_query(criteria) do
    try do
      query = from a in Asset
      build_search_conditions(query, criteria)
      {:ok, query}
    catch
      _ -> {:error, :bad_request}
    end
  end

  defp build_search_conditions(query, criteria) do
    Enum.reduce(criteria, query, fn
      %{"condition" => "OR", "criteria" => sub_criteria}, query ->
        or_conditions = Enum.map(sub_criteria, fn sub_crit ->
          build_condition(query, sub_crit["field"], sub_crit["operator"], sub_crit["value"])
        end)
       combined_or_conditions = Enum.reduce(or_conditions, &dynamic([q], ^&1 or ^&2))
       from q in query, where: ^combined_or_conditions

      %{"field" => field, "operator" => operator, "value" => value}, query ->
        build_condition(query, field, operator, value)
    end)
  end

  defp build_condition(query, "tags", operator, %{"key" => key, "value" => value}) do
    case operator do
      "==" -> from q in query, where: fragment("? @> ?", q.tags, ^[%{"key" => key, "value" => value}])
      "!=" -> from q in query, where: not(fragment("? @> ?", q.tags, ^[%{"key" => key, "value" => value}]))
      "like" -> from q in query, where: fragment("? @> ? ilike ?", q.tags, ^key, ^"%#{value}%")
      "in" -> from q in query, where: fragment("? @> ? in (?)", q.tags, ^key, ^value)
      "not in" -> from q in query, where: fragment("? @> ? not in (?)", q.tags, ^key, ^value)
      _ ->
        raise "Unsupported operator for tags: #{operator}"
    end
  end

  defp build_condition(query, "group_names", operator, value) do
    case operator do
      "==" -> from q in query, where: ^value in q.group_names
      "!=" -> from q in query, where: not( ^value in q.group_names)
      "like" -> from q in query, where: fragment("?::text ilike ?", q.group_names, ^"%#{value}%")
      _ -> raise "Unsupported operator for group_names: #{operator}"
    end
  end

  defp build_condition(query, field, operator, value) do
    field_atom = String.to_existing_atom(field)
    case operator do
      "==" -> from q in query, where: field(q, ^field_atom) == ^value
      "!=" -> from q in query, where: field(q, ^field_atom) != ^value
      "like" -> from q in query, where: ilike(field(q, ^field_atom), ^"%#{value}%")
      "in" -> from q in query, where: field(q, ^field_atom) in ^value
      "not in" -> from q in query, where: field(q, ^field_atom) not in ^value
      _ -> raise "Unsupported operator: #{operator}"
    end
  end

  def assign_assets_to_group(%Group{id: _group_id, rules: rules, name: group_name}) do
    parsed_rules = parse_rules(rules)
    query = from a in Asset
    query = AssetQueries.apply_rules(query, parsed_rules)

    update_query = from a in query, update: [set: [group_names: fragment("CASE WHEN ? IS NULL OR ? = '' THEN ? ELSE ? || ',' || ? END", a.group_names, a.group_names, ^group_name, a.group_names, ^group_name)]]
    case Repo.update_all(update_query, []) do
      {count, _} when count > 0 -> {:ok, count}
      {0, _} -> {:error, "No assets found for the given rules"}
      {:error, _} -> {:error, "Failed to assign assets to group"}
    end
  end

  defp parse_rules(rules) do
    rules
    |> Jason.decode!()
    |> Enum.map(fn rule ->
      %{
        "field" => rule["field"],
        "operator" => rule["operator"],
        "value" => rule["value"]
      }
    end)
  end
end
