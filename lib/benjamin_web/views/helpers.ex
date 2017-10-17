defmodule BenjaminWeb.ViewHelpers do
  import Number.Currency

  def is_active(%Plug.Conn{} = conn, helper_fun, path) when is_atom(helper_fun) and is_atom(path) do
    if conn.request_path == apply(BenjaminWeb.Router.Helpers, helper_fun, [conn, path]) do
      "active"
    else
      ""
    end
  end

  def format_amount(amount), do: number_to_currency amount, unit: "zl"

  def selected_value(nil, _id), do: ""
  def selected_value([], _id), do: ""
  def selected_value([_|_] = coll, id, key \\ :name) do
    coll
    |> Enum.find(&(&1.id == id))
    |> case do
      %{} = res -> Map.get(res, key)
      _ -> ""
    end
  end

  def format_date(%Date{} = date), do: "#{date.day}.#{date.month}.#{date.year}"
  def format_date(_), do: ""


  alias Benjamin.Finanses.Saving

  def sum_transactions(transactions) do
    transactions
    |> Saving.sum_transactions
  end

  def total_savings(savings) do
    savings
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(sum_transactions(&1.transactions), &2)))
    |> format_amount
  end

  def total_transactions(transactions) do
    transactions
    |> sum_transactions
    |> format_amount
  end

  def sum_deposits(transactions) do
    transactions
    |> Enum.filter(&(&1.type == "deposit"))
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end

  def total_transactions_for_budget(transactions) do
    transactions
    |> sum_deposits
    |> format_amount
  end

end
