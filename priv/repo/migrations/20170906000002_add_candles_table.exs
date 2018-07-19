defmodule Cryptozaur.Repo.Migrations.AddCandlesTable do
  use Ecto.Migration

  def change do
    create table(:candles) do
      add(:symbol, :string, null: false)
      add(:open, :float, null: false)
      add(:high, :float, null: false)
      add(:low, :float, null: false)
      add(:close, :float, null: false)
      add(:buys, :float, null: false)
      add(:sells, :float, null: false)
      # in seconds
      add(:resolution, :integer, null: false)
      add(:timestamp, :naive_datetime, null: false)
    end

    # to search faster
    create(unique_index(:candles, [:symbol, :timestamp, :resolution], name: "symbol_timestamp_resolution_candles_index"))
  end
end
