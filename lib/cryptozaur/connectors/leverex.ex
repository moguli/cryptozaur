defmodule Cryptozaur.Connectors.Leverex do
  require OK
  import Cryptozaur.Utils
  alias Cryptozaur.Model.{Ticker, Balance, Order}
  alias Cryptozaur.Drivers.LeverexRest, as: Rest
  alias Cryptozaur.Connector

  def get_balances(key, secret) do
    OK.for do
      rest <- Cryptozaur.DriverSupervisor.get_driver(key, secret, Rest)
      results <- Rest.get_balances(rest)
      balances = Enum.map(results, &to_balance(&1))
    after
      balances
    end
  end

  defp to_balance(%{"asset" => currency, "available_amount" => _available_amount, "total_amount" => total_amount}) do
    %Balance{currency: currency, amount: total_amount}
  end

  defp to_symbol(base, quote) do
    "LEVEREX:#{to_pair(base, quote)}"
  end

  defp to_pair(base, quote) do
    "#{base}:#{quote}"
  end

  def get_min_amount(base, _price) do
    case base do
      _ -> 0.00000001
    end
  end

  def get_amount_precision(base, _quote) do
    case base do
      _ -> 8
    end
  end

  def get_price_precision(_base, quote) do
    case quote do
      _ -> 8
    end
  end

  def get_tick(_base, quote) do
    case quote do
      _ -> 0.00000001
    end
  end

  defp parse_timestamp(string) do
    NaiveDateTime.from_iso8601!(string)
  end

  def get_link(base, quote) do
    "https://www.leverex.io/market/#{base}:#{quote}"
  end
end
