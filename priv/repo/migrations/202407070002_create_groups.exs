defmodule MyApp.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :rules, {:array, :map}

      timestamps()
    end
  end
end
