defmodule MyApp.Repo.Migrations.UseJsonbForRules do
  use Ecto.Migration

  def change do
    create table(:groups_new) do
      add :name, :string
      add :rules, :text

      timestamps()
    end

    drop table(:groups)

    rename table(:groups_new), to: table(:groups)
  end
end
