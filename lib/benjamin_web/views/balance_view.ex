defmodule BenjaminWeb.BalanceView do
  use BenjaminWeb, :view

  @months %{
    1 => "January",
    2 => "February",
    3 => "March",
    4 => "April",
    5 => "May",
    6 => "June",
    7 => "July",
    8 => "August",
    9 => "September",
    10 => "October",
    11 => "November",
    12 => "December"
  }

  def month_nrb_to_name(month_nbr) when month_nbr in 1..12 do
    Map.get @months, month_nbr
  end

  def month_to_select do
    Enum.map(@months, &{elem(&1, 1), elem(&1, 0)})
  end

  def year_to_select() do
    current_year = Date.utc_today.year
    (current_year - 10)..current_year
  end
end
