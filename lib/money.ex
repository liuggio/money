defmodule Money do
  import Kernel, except: [abs: 1]

  @moduledoc """
  Defines a `Money` struct along with convenience methods for working with currencies.

  ## Example:

      iex> money = Money.new(500, :USD)
      %Money{amount: 500, currency: :USD}
      iex> money = Money.add(money, 550)
      %Money{amount: 1050, currency: :USD}
      iex> Money.to_string(money)
      "$10.50"

  ## Configuration options

  You can set defaults in your Mix configuration to make working with `Money` a little easier.

  ## Configuration:

      config :money,
        default_currency: :EUR,  # this allows you to do Money.new(100)
        separator: ".",          # change the default thousands separator for Money.to_string
        delimiter: ",",          # change the default decimal delimeter for Money.to_string
        symbol: false            # don’t display the currency symbol in Money.to_string
        symbol_on_right: false,  # position the symbol
        symbol_space: false      # add a space between symbol and number
        fractional_unit: false   # don’t display the remainder or the delimeter

  ### Currency configuration
  Sometimes you will need to setup different formatting options for each currency. You can do so by creating different
  configuration for each currency you need to be applied on.
  If some options are not found for the currency, it will fallback then to global and default options.

      config :money, :EUR
        separator: "_",
        symbol: true,
        symbol_on_right: true,
        symbol_space: true
  """

  @type t :: %__MODULE__{
    amount: integer,
    currency: atom
  }

  defstruct amount: 0, currency: :USD

  alias Money.{Currency, Config}

  @spec new(integer) :: t
  @doc ~S"""
  Create a new `Money` struct using a default currency.
  The default currency can be set in the system Mix config.

  ## Example Config:

      config :money,
        default_currency: :USD

  ## Example:

      Money.new(123)
      %Money{amount: 123, currency: :USD}
  """
  def new(amount) do
    currency = Config.get(:default_currency)
    if currency do
      new(amount, currency)
    else
      raise ArgumentError, "to use Money.new/1 you must set a default currency in your application config."
    end
  end

  @spec new(integer, atom | String.t) :: t
  @doc """
  Create a new `Money` struct from currency sub-units (cents)

  ## Example:

      iex> Money.new(1_000_00, :USD)
      %Money{amount: 1_000_00, currency: :USD}
  """
  def new(int, currency) when is_integer(int),
    do: %Money{amount: int, currency: Currency.to_atom(currency)}

  @spec parse(String.t | float, atom | String.t, Keyword.t) :: {:ok, t}
  @doc ~S"""
  Parse a value into a `Money` type.

  The following options are available:

    - `separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    - `delimeter` - default `"."`, sets the decimal delimeter.
      "1.23"

  ## Examples:

      iex> Money.parse("$1,234.56", :USD)
      {:ok, %Money{amount: 123456, currency: :USD}}
      iex> Money.parse("1.234,56", :EUR, separator: ".", delimeter: ",")
      {:ok, %Money{amount: 123456, currency: :EUR}}
      iex> Money.parse("1.234,56", :WRONG)
      :error
      iex> Money.parse(1_234.56, :USD)
      {:ok, %Money{amount: 123456, currency: :USD}}
      iex> Money.parse(-1_234.56, :USD)
      {:ok, %Money{amount: -123456, currency: :USD}}
  """
  def parse(value, currency \\ nil, opts \\ [])
  def parse(value, nil, opts) do
    currency = Config.get(:default_currency)
    if currency do
      parse(value, currency, opts)
    else
      raise ArgumentError, "to use Money.new/1 you must set a default currency in your application config."
    end
  end
  def parse(str, currency, opts) when is_binary(str) do
    try do
      {_separator, delimeter} = get_parse_options(currency, opts)
      value = str
      |> prepare_parse_string(delimeter)
      |> add_missing_leading_digit
      case Float.parse(value) do
        {float, _} -> parse(float, currency, [])
        :error -> :error
      end
    rescue
      _ -> :error
    end
  end
  def parse(float, currency, _opts) when is_float(float) do
    {:ok, new(round(float * Currency.sub_units_count!(currency)), currency)}
  end

  defp prepare_parse_string(characters, delimeter, acc \\ [])
  defp prepare_parse_string([], _delimeter, acc),
    do: Enum.reverse(acc) |> Enum.join
  defp prepare_parse_string(["-" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["-" | acc])
  defp prepare_parse_string(["0" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["0" | acc])
  defp prepare_parse_string(["1" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["1" | acc])
  defp prepare_parse_string(["2" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["2" | acc])
  defp prepare_parse_string(["3" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["3" | acc])
  defp prepare_parse_string(["4" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["4" | acc])
  defp prepare_parse_string(["5" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["5" | acc])
  defp prepare_parse_string(["6" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["6" | acc])
  defp prepare_parse_string(["7" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["7" | acc])
  defp prepare_parse_string(["8" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["8" | acc])
  defp prepare_parse_string(["9" | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["9" | acc])
  defp prepare_parse_string([delimeter | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, ["." | acc])
  defp prepare_parse_string([_head | tail], delimeter, acc),
    do: prepare_parse_string(tail, delimeter, acc)

  defp prepare_parse_string(string, delimeter, _acc),
    do: prepare_parse_string(String.codepoints(string), delimeter)

  defp add_missing_leading_digit(<< "-." >> <> tail),
    do: "-0." <> tail
  defp add_missing_leading_digit(<< "." >> <> tail),
    do: "0." <> tail
  defp add_missing_leading_digit(str), do: str

  @spec parse(String.t | float, atom | String.t, Keyword.t) :: t
  @doc ~S"""
  Parse a value into a `Money` type.
  Similar to `parse/3` but returns a `%Money{}` or raises an error if parsing fails.

  ## Example:

      iex> Money.parse!("1,234.56", :USD)
      %Money{amount: 123456, currency: :USD}
      iex> Money.parse!("wrong", :USD)
      ** (ArgumentError) unable to parse "wrong"
  """
  def parse!(value, currency \\ nil, opts \\ []) do
    case parse(value, currency, opts) do
      {:ok, money} -> money
      :error -> raise ArgumentError, "unable to parse #{inspect(value)}"
    end
  end

  @spec compare(t, t) :: t
  @doc ~S"""
  Compares two `Money` structs with each other.
  They must each be of the same currency and then their amounts are compared

  ## Example:

      iex> Money.compare(Money.new(100, :USD), Money.new(100, :USD))
      0
      iex> Money.compare(Money.new(100, :USD), Money.new(101, :USD))
      -1
      iex> Money.compare(Money.new(101, :USD), Money.new(100, :USD))
      1
  """
  def compare(%Money{currency: cur} = a, %Money{currency: cur} = b) do
    case a.amount - b.amount do
                    x when x >  0 -> 1
                    x when x <  0 -> -1
                    x when x == 0 -> 0
    end
  end
  def compare(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec zero?(t) :: boolean
  @doc ~S"""
  Returns true if the amount of a `Money` struct is zero

  ## Example:

      iex> Money.zero?(Money.new(0, :USD))
      true
      iex> Money.zero?(Money.new(1, :USD))
      false
  """
  def zero?(%Money{amount: amount}) do
    amount == 0
  end

  @spec positive?(t) :: boolean
  @doc ~S"""
  Returns true if the amount of a `Money` is greater than zero

  ## Example:

      iex> Money.positive?(Money.new(0, :USD))
      false
      iex> Money.positive?(Money.new(1, :USD))
      true
      iex> Money.positive?(Money.new(-1, :USD))
      false
  """
  def positive?(%Money{amount: amount}) do
    amount > 0
  end

  @spec negative?(t) :: boolean
  @doc ~S"""
  Returns true if the amount of a `Money` is less than zero

  ## Example:

      iex> Money.negative?(Money.new(0, :USD))
      false
      iex> Money.negative?(Money.new(1, :USD))
      false
      iex> Money.negative?(Money.new(-1, :USD))
      true
  """
  def negative?(%Money{amount: amount}) do
    amount < 0
  end

  @spec equals?(t, t) :: boolean
  @doc ~S"""
  Returns true if two `Money` of the same currency have the same amount

  ## Example:

      iex> Money.equals?(Money.new(100, :USD), Money.new(100, :USD))
      true
      iex> Money.equals?(Money.new(101, :USD), Money.new(100, :USD))
      false
  """
  def equals?(%Money{amount: amount, currency: cur}, %Money{amount: amount, currency: cur}), do: true
  def equals?(%Money{currency: cur}, %Money{currency: cur}), do: false
  def equals?(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec neg(t) :: t
  @doc ~S"""
  Returns a `Money` with the amount negated.

  ## Examples:

      iex> Money.new(100, :USD) |> Money.neg
      %Money{amount: -100, currency: :USD}
      iex> Money.new(-100, :USD) |> Money.neg
      %Money{amount: 100, currency: :USD}
  """
  def neg(%Money{amount: amount, currency: cur}),
    do: %Money{amount: -amount, currency: cur}

  @spec abs(t) :: t
  @doc ~S"""
  Returns a `Money` with the arithmetical absolute of the amount.

  ## Examples:

      iex> Money.new(-100, :USD) |> Money.abs
      %Money{amount: 100, currency: :USD}
      iex> Money.new(100, :USD) |> Money.abs
      %Money{amount: 100, currency: :USD}
  """
  def abs(%Money{amount: amount, currency: cur}),
    do: %Money{amount: Kernel.abs(amount), currency: cur}

  @spec add(t, t | integer | float) :: t
  @doc ~S"""
  Adds two `Money` together or an integer (cents) amount to a `Money`

  ## Example:

      iex> Money.add(Money.new(100, :USD), Money.new(50, :USD))
      %Money{amount: 150, currency: :USD}
      iex> Money.add(Money.new(100, :USD), 50)
      %Money{amount: 150, currency: :USD}
      iex> Money.add(Money.new(100, :USD), 5.55)
      %Money{amount: 655, currency: :USD}
  """
  def add(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(a + b, cur)
  def add(%Money{amount: amount, currency: cur}, addend) when is_integer(addend),
    do: Money.new(amount + addend, cur)
  def add(%Money{} = m, addend) when is_float(addend),
    do: add(m, round(addend * 100))
  def add(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec subtract(t, t | integer | float) :: t
  @doc ~S"""
  Subtracts one `Money` from another or an integer (cents) from a `Money`

  ## Example:

      iex> Money.subtract(Money.new(150, :USD), Money.new(50, :USD))
      %Money{amount: 100, currency: :USD}
      iex> Money.subtract(Money.new(150, :USD), 50)
      %Money{amount: 100, currency: :USD}
      iex> Money.subtract(Money.new(150, :USD), 1.25)
      %Money{amount: 25, currency: :USD}
  """
  def subtract(%Money{amount: a, currency: cur}, %Money{amount: b, currency: cur}),
    do: Money.new(a - b, cur)
  def subtract(%Money{amount: a, currency: cur}, subtractend) when is_integer(subtractend),
    do: Money.new(a - subtractend, cur)
  def subtract(%Money{} = m, subtractend) when is_float(subtractend),
    do: subtract(m, round(subtractend * 100))
  def subtract(a, b), do: fail_currencies_must_be_equal(a, b)

  @spec multiply(t, integer | float) :: t
  @doc ~S"""
  Multiplies a `Money` by an amount

  ## Example:
      iex> Money.multiply(Money.new(100, :USD), 10)
      %Money{amount: 1000, currency: :USD}
      iex> Money.multiply(Money.new(100, :USD), 1.5)
      %Money{amount: 150, currency: :USD}
  """
  def multiply(%Money{amount: amount, currency: cur}, multiplier) when is_integer(multiplier),
    do: Money.new(amount * multiplier, cur)
  def multiply(%Money{amount: amount, currency: cur}, multiplier) when is_float(multiplier),
    do: Money.new(round(amount * multiplier), cur)

  @spec divide(t, integer) :: [t]
  @doc ~S"""
  Divides up `Money` by an amount

  ## Example:
      iex> Money.divide(Money.new(100, :USD), 2)
      [%Money{amount: 50, currency: :USD}, %Money{amount: 50, currency: :USD}]
      iex> Money.divide(Money.new(101, :USD), 2)
      [%Money{amount: 51, currency: :USD}, %Money{amount: 50, currency: :USD}]
  """
  def divide(%Money{amount: amount, currency: cur}, denominator) when is_integer(denominator) do
    value = div(amount, denominator)
    rem   = rem(amount, denominator)
    do_divide(cur, value, rem, denominator, [])
  end

  defp do_divide(_currency, _value, _rem, 0, acc), do: acc |> Enum.reverse
  defp do_divide(currency, value, 0, count, acc) do
    count = decrement_abs(count)
    acc   = [new(value, currency) | acc]
    do_divide(currency, value, 0, count, acc)
  end
  defp do_divide(currency, value, rem, count, acc) do
    rem   = decrement_abs(rem)
    count = decrement_abs(count)
    acc   = [new(increment_abs(value), currency) | acc]
    do_divide(currency, value, rem, count, acc)
  end

  defp increment_abs(n) when n >= 0, do: n + 1
  defp increment_abs(n) when n < 0, do: n - 1
  defp decrement_abs(n) when n >= 0, do: n - 1
  defp decrement_abs(n) when n < 0, do: n + 1

  @spec to_string(t, Keyword.t) :: String.t
  @doc ~S"""
  Converts a `Money` struct to a string representation

  The following options are available:

    - `separator` - default `","`, sets the separator for groups of thousands.
      "1,000"
    - `delimeter` - default `"."`, sets the decimal delimeter.
      "1.23"
    - `symbol` - default `true`, sets whether to display the currency symbol or not.
    - `symbol_on_right` - default `false`, display the currency symbol on the right of the number, eg: 123.45€
    - `symbol_space` - default `false`, add a space between currency symbol and number, eg: € 123,45 or 123.45 €
    - `fractional_unit` - default `true`, show the remaining units after the delimeter

  ## Example:

      iex> Money.to_string(Money.new(123456, :GBP))
      "£1,234.56"
      iex> Money.to_string(Money.new(123456, :EUR), separator: ".", delimeter: ",")
      "€1.234,56"
      iex> Money.to_string(Money.new(123456, :EUR), symbol: false)
      "1,234.56"
      iex> Money.to_string(Money.new(123456, :EUR), symbol: false, separator: "")
      "1234.56"
      iex> Money.to_string(Money.new(123456, :EUR), fractional_unit: false)
      "€1,234"

  It can also be interpolated (It implements the String.Chars protocol)
  To control the formatting, you can use the above options in your config,
  more information is in the introduction to `Money`

  ## Example:

      iex> "Total: #{Money.new(100_00, :USD)}"
      "Total: $100.00"
  """
  def to_string(%Money{}=money, opts \\ []) do
    {separator, delimeter, symbol, symbol_on_right, symbol_space, fractional_unit} = get_display_options(money, opts)
    number = format_number(money, separator, delimeter, fractional_unit, money)
    sign = if negative?(money), do: "-"
    space = if symbol_space, do: " "

    parts = if symbol_on_right do
              [sign, number, space, symbol]
            else
              [symbol, space, sign, number]
            end
    parts |> Enum.join |> String.trim_leading
  end

  defp format_number(%Money{amount: amount}, separator, delimeter, fractional_unit, money) do
    exponent = Currency.exponent(money)
    sub_units_count = Currency.sub_units_count!(money)
    [super_unit | sub_unit] = Kernel.abs(amount/sub_units_count) |> :erlang.float_to_binary(decimals: exponent) |> String.split(".")
    super_unit = super_unit |> reverse_group(3) |> Enum.join(separator)
    if fractional_unit && sub_unit != [] do
      [super_unit, sub_unit] |> Enum.join(delimeter)
    else
      super_unit
    end
  end

  defp get_display_options(m, opts) do
    {separator, delimeter} = get_parse_options(m.currency, opts)

    default_symbol = Config.get(:symbol, m.currency)
    default_symbol_on_right = Config.get(:symbol_on_right, m.currency)
    default_symbol_space = Config.get(:symbol_space, m.currency)
    default_fractional_unit = Config.get(:fractional_unit, m.currency)

    symbol = if Keyword.get(opts, :symbol, default_symbol), do: Currency.symbol(m), else: ""
    symbol_on_right = Keyword.get(opts, :symbol_on_right, default_symbol_on_right)
    symbol_space = Keyword.get(opts, :symbol_space, default_symbol_space)
    fractional_unit = Keyword.get(opts, :fractional_unit, default_fractional_unit)

    {separator, delimeter, symbol, symbol_on_right, symbol_space, fractional_unit}
  end

  defp get_parse_options(currency, opts) do
    default_separator = Config.get(:separator, currency)
    default_delimeter = Config.get(:delimeter, currency)

    separator = Keyword.get(opts, :separator, default_separator)
    delimeter = Keyword.get(opts, :delimeter, default_delimeter)

    {separator, delimeter}
  end

  defp fail_currencies_must_be_equal(a, b) do
    raise ArgumentError, message: "Currency of #{a.currency} must be the same as #{b.currency}"
  end

  defp reverse_group(str, count) when is_binary(str) do
    reverse_group(str, Kernel.abs(count), [])
  end
  defp reverse_group("", _count, list) do
    list
  end
  defp reverse_group(str, count, list) do
    {first, last} = String.split_at(str, -count)
    reverse_group(first, count, [last | list])
  end

  defimpl String.Chars do
    def to_string(%Money{} = m) do
      Money.to_string(m)
    end
  end
end
