defmodule MyApp.AssetQueries do
  import Ecto.Query

  def apply_rules(query, rules) do
    IO.inspect(rules, label: "Rules list")
    Enum.reduce(rules, query, fn rule, acc_query ->
      build_condition(acc_query, rule)
    end)
  end

  defp build_condition(query, %{"field" => field, "operator" => operator, "value" => value}) do
    IO.inspect(%{field: field, operator: operator, value: value}, label: "Current Rule")
    case operator do
      "==" -> from a in query, where: field(a, ^String.to_existing_atom(field)) == ^value
      "!=" -> from a in query, where: field(a, ^String.to_existing_atom(field)) != ^value
      _ -> raise "Unsupported operator: #{operator}"
    end
  end
end
