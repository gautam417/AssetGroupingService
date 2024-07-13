defmodule MyApp.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :type, :tags, :cloud_account, :owner_id, :region, :group_names]}
  schema "assets" do
    field :name, :string
    field :type, :string
    field :tags, {:array, :map}
    field :cloud_account, :map
    field :owner_id, :string
    field :region, :string
    field :group_names, {:array, :string}, default: []

    timestamps()
  end

  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [:name, :type, :tags, :cloud_account, :owner_id, :region, :group_names])
    |> validate_required([:name, :type, :owner_id])
  end

  defimpl Jason.Encoder do
    def encode(asset, _opts) do
      %{
        id: asset.id,
        name: asset.name,
        type: asset.type,
        tags: asset.tags,
        cloud_account: asset.cloud_account,
        owner_id: asset.owner_id,
        region: asset.region,
        group_names: asset.group_names
      }
      |> Jason.encode!()
    end
  end
end
