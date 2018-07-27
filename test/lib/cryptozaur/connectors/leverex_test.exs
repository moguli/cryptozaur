defmodule Cryptozaur.Connectors.LeverexTest do
  use ExUnit.Case
  import OK, only: [success: 1]

  import Cryptozaur.Case
  alias Cryptozaur.{Repo, Metronome, Connector}
  alias Cryptozaur.Model.{Balance}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    {:ok, metronome} = start_supervised(Metronome)
    {:ok, _} = start_supervised(Cryptozaur.DriverSupervisor)
    %{metronome: metronome}
  end

  test "get_info" do
    produce_driver(
      [
        {
          {:get_info, []},
          success(%{"markets" => %{}, "assets" => %{}})
        }
      ],
      Cryptozaur.Drivers.LeverexRest,
      :public
    )

    assert success(%{"markets" => %{}, "assets" => %{}}) == Connector.get_info("LEVEREX")
  end

  test "get_balances" do
    key =
      produce_driver(
        [
          {
            {:get_balances},
            success([
              %{
                "asset" => "BTCT",
                "available_amount" => 5.0,
                "total_amount" => 10.0
              },
              %{
                "asset" => "ETHT",
                "available_amount" => 500.0,
                "total_amount" => 1000.0
              }
            ])
          }
        ],
        Cryptozaur.Drivers.LeverexRest
      )

    assert success([
             %Balance{available_amount: 5.0, total_amount: 10.0, currency: "BTCT"},
             %Balance{available_amount: 500.0, total_amount: 1000.0, currency: "ETHT"}
           ]) = Connector.get_balances("LEVEREX", key, "secret")
  end

  test "place_order" do
    key =
      produce_driver(
        [
          {
            {:place_order, "ETH_D:BTC_D", 1, 0.0000100, []},
            success(%{
              "called_amount" => 1.00000000,
              "external_id" => nil,
              "fee" => 0.00000000,
              "filled_amount" => 0.00000000,
              "id" => 4,
              "inserted_at" => "2018-07-27T13:11:53.200832",
              "is_active" => true,
              "is_cancelled" => false,
              "limit_price" => 0.00001000,
              "symbol" => "ETH_D:BTC_D",
              "trigger_price" => nil,
              "triggered_at" => "2018-07-27T13:11:53.200536",
              "updated_at" => "2018-07-27T13:11:53.200840"
            })
          }
        ],
        Cryptozaur.Drivers.LeverexRest
      )

    assert success("4") == Connector.place_order("LEVEREX", key, "secret", "ETH_D", "BTC_D", 1, 0.00001)
  end

  test "cancel_order" do
    key =
      produce_driver(
        [
          {
            {:cancel_order, "4", []},
            success(true)
          }
        ],
        Cryptozaur.Drivers.LeverexRest
      )

    assert success(true) == Connector.cancel_order("LEVEREX", key, "secret", "ETH_D", "BTC_D", "4")
  end
end
