defmodule Mix.Tasks.Buy.Test do
  use Cryptozaur.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]

  test "user can place a buy order", %{opts: opts} do
    use_cassette "tasks/buy_ok", match_requests_on: [:query] do
      result = Mix.Tasks.Buy.run(opts ++ ["leverex", "ETH_D:BTC_D", "0.00000001", "20"])

      assert {:ok, order} = result
      assert order.price == 0.00000001
      assert order.amount_requested == 20.0
    end
  end

  test "user can place a buy order and see result in JSON format", %{opts: opts} do
    use_cassette "tasks/buy_ok", match_requests_on: [:query] do
      result = Mix.Tasks.Buy.run(opts ++ ["--format", "json", "leverex", "ETH_D:BTC_D", "0.00000001", "20"])

      assert {:ok, _} = result
      assert_received {:mix_shell, :info, [msg]}
      order = Poison.decode!(msg, keys: :atoms!)
      assert order.price == 0.00000001
      assert order.amount_requested == 20.0
    end
  end

  test "user can't place a buy order with insufficient funds", %{opts: opts} do
    use_cassette "tasks/buy_error_not_enough_balance", match_requests_on: [:query] do
      result = Mix.Tasks.Buy.run(opts ++ ["leverex", "ETH_D:BTC_D", "0.1", "20000000"])

      assert {:error,
              %{
                "details" => %{
                  "asset" => "BTC_D",
                  "available" => 10.00000000,
                  "requested" => 2_002_000.00000000,
                  "symbol" => "ETH_D:BTC_D",
                  "user_id" => 1
                },
                "type" => "not_enough_balance"
              }} = result
    end
  end

  test "user can't place a buy order on non-existent market", %{opts: opts} do
    use_cassette "tasks/buy_error_invalid_symbol", match_requests_on: [:query] do
      result = Mix.Tasks.Buy.run(opts ++ ["leverex", "ULTRATRASH:MEGATRASH", "0.00000001", "20"])

      assert {:error, error} = result

      assert error == %{
               "details" => %{"symbol" => "ULTRATRASH:MEGATRASH"},
               "type" => "invalid_symbol"
             }
    end
  end
end
