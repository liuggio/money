defmodule Money.ConfigTest do
  use ExUnit.Case

  alias Money.Config

  setup_all do
    # Global config
    Application.put_env(:money, :default_currency, :EUR)
    Application.put_env(:money, :separator, "_")
    Application.put_env(:money, :fractional_unit, false)
    Application.put_env(:money, :symbol, false)
    Application.put_env(:money, :symbol_on_right, false)
    Application.put_env(:money, :symbol_space, false)

    # EUR Currency config override
    Application.put_env(:money, :EUR, %{
      fractional_unit: true,
      symbol: true,
      symbol_on_right: true,
      symbol_space: true
    })

    on_exit fn ->
      Application.delete_env(:money, :default_currency)
      Application.delete_env(:money, :separator)
      Application.delete_env(:money, :delimeter)
      Application.delete_env(:money, :fractional_unit)
      Application.delete_env(:money, :symbol)
      Application.delete_env(:money, :symbol_on_right)
      Application.delete_env(:money, :symbol_space)
      Application.delete_env(:money, :EUR)
    end
  end

  describe "get/2" do
    test "returns EUR configured options" do
      assert Config.get(:fractional_unit, :EUR) == true
      assert Config.get(:symbol, :EUR) == true
      assert Config.get(:symbol_on_right, :EUR) == true
      assert Config.get(:symbol_space, :EUR) == true
    end

    test "fallbacks to global option if EUR has not the option configured" do
      assert Config.get(:separator, :EUR) == "_"
    end

    test "fallbacks to default option if EUR and global option is not configured" do
      assert Config.get(:delimeter, :EUR) == "."
    end
  end

  describe "get/1" do
    test "return the given global configured option" do
      assert Config.get(:default_currency) == :EUR
      assert Config.get(:separator) == "_"
      assert Config.get(:fractional_unit) == false
      assert Config.get(:symbol) == false
      assert Config.get(:symbol_on_right) == false
      assert Config.get(:symbol_space) == false
    end

    test "fallbacks to default option if option is not cofigured as global" do
      assert Config.get(:delimeter) == "."
    end
  end
end
