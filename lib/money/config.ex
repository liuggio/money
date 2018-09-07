defmodule Money.Config do
  @moduledoc ~S"""
  Defines helper methods to retrieve Money configuration by currency.
  """

  @default_options %{
    symbol: true,
    symbol_on_right: false,
    symbol_space: false,
    fractional_unit: true,
    separator: ",",
    delimeter: "."
  }

  @spec get(atom, atom) :: binary | true | false
  @spec get(atom) :: binary | true | false

  @doc ~S"""
  Retrieve configuration options following the fallback tree for default options:
  - If `currency` argument is given it will try to retrive that `option` from the config about the given currency.
  - If this option is not found or no currency is given, then the global config `option` will be returned.
  - If no value for that `option` is found on the global config, then the default option is returned.
  """
  def get(option, currency),
    do: Application.get_env(:money, currency, [])[option] || get(option)
  def get(option),
    do: Application.get_env(:money, option, @default_options[option])
end
