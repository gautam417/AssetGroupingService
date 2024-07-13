defmodule MyApp.Repo.Migrations.CreateAssets do
  use Ecto.Migration

  def change do
    create table(:assets) do
      add :name, :string
      add :type, :string
      add :tags, {:array, :map}, null: false, default: []
      add :cloud_account, :map
      add :owner_id, :string
      add :region, :string
      add :group_names, {:array, :string}, default: []

      timestamps()
    end
  end
end
