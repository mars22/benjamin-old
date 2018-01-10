defmodule BenjaminWeb.ViewHelpersTest do
  use BenjaminWeb.ConnCase, async: true
  alias BenjaminWeb.ViewHelpers

  test "format_amount/1 return formatted as currency decimal number" do
    assert ViewHelpers.format_amount(Decimal.new(12.3), "zł") == "12,30 zł"
  end

  describe "selected_value" do

    test "selected_value/2 return selected name" do
      coll = [%{id: 1, name: "test1"}, %{id: 2, name: "test3"}]
      assert ViewHelpers.selected_value(coll, 1) == "test1"
      coll = [%{id: 1, name: "test1"}]
      assert ViewHelpers.selected_value(coll, 1) == "test1"
    end

    test "selected_value/2 return empty string if coll is empty or nil" do
      assert ViewHelpers.selected_value([], 1) == ""
      assert ViewHelpers.selected_value(nil, 1) == ""
    end

    test "selected_value/2 return empty string if id can't be found" do
      coll = [%{id: 1, name: "test1"}, %{id: 2, name: "test3"}]
      assert ViewHelpers.selected_value(coll, 3) == ""
    end
  end
end
