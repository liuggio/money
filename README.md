# Money
[![Build Status](https://travis-ci.org/liuggio/money.svg)](https://travis-ci.org/liuggio/money)

Elixir library for working with Money safer, easier, and fun,
is an interpretation of the Fowler's Money pattern in fun.prog.

> "If I had a dime for every time I've seen someone use FLOAT to store currency, I'd have $999.997634" -- [Bill Karwin](https://twitter.com/billkarwin/status/347561901460447232)

In short: You shouldn't represent monetary values by a float. Wherever
you need to represent money, use `Money`.

Documentation can be found at [https://hexdocs.pm/money/Money.html](https://hexdocs.pm/money/Money.html) on [HexDocs](https://hexdocs.pm)

## USAGE

```elixir
five_eur         = Money.new(500, :EUR)             # %Money{amount: 500, currency: :EUR}
ten_eur          = Money.add(five_eur, five_eur)    # %Money{amount: 10_00, currency: :EUR}
hundred_eur      = Money.multiply(ten_eur, 10)      # %Money{amount: 100_00, currency: :EUR}
ninety_nine_eur  = Money.subtract(hundred_eur, 1)   # %Money{amount: 99_00, currency: :EUR}
shares           = Money.divide(ninety_nine_eur, 2)
[%Money{amount: 50, currency: :EUR}, %Money{amount: 49, currency: :EUR}]

Money.equals?(five_eur, Money.new(500, :EUR)) # true
Money.zero?(five_eur);                        # false
Money.positive?(five_eur);                    # true

Money.Currency.symbol(:USD)                   # $
Money.Currency.symbol(Money.new(500, :AFN))   # ؋
Money.Currency.name(Money.new(500, :AFN))     # Afghani

Money.to_string(Money.new(500, :CNY))         # ¥ 5.00
Money.to_string(Money.new(1_234_56, :EUR), separator: ".", delimeter: ",", symbol: false)
"1.234,56"
Money.to_string(Money.new(1_234_56, :USD), fractional_unit: false)  # "$1,234"
```

### Money.Sigils

```elixir
# Sigils for Money
import Money.Sigils

iex> ~M[1000]USD
%Money{amount: 1000, currency: :USD}

# If you have a default currency configured (e.g. to GBP), you can do
iex> ~M[1000]
%Money{amount: 1000, currency: :GBP}
```

### Money.Currency

```elixir
# Currency convenience methods
import Money.Currency, only: [usd: 1, eur: 1, afn: 1]

iex> usd(100_00)
%Money{amount: 10000, currency: :USD}
iex> eur(100_00)
%Money{amount: 10000, currency: :EUR}
iex> afn(100_00)
%Money{amount: 10000, currency: :AFN}

Money.Currency.symbol(:USD)     # $
Money.Currency.symbol(afn(500)) # ؋
Money.Currency.name(afn(500))   # Afghani
Money.Currency.get(:AFN)        # %{name: "Afghani", symbol: "؋"}
```

### Money.Ecto.Type

Bring `Money` to your Ecto project.
The underlying database type is `integer`

```elixir
# migration
create table(:my_table) do
  add :amount, :integer
end

# model/schema
schema "my_table" do
  field :amount, Money.Ecto.Type
end
```

### Phoenix.HTML.Safe

Bring `Money` to your Phoenix project.
If you are using Phoenix, you can include money objects directly into your output and they will be correctly escaped.

```elixir
<b><%= Money.new(12345,67, :GBP) %></b>
```

## INSTALLATION

Money comes with no required dependencies.

Add the following to your `mix.exs`:

```elixir
def deps do
  [{:money, "~> 1.2.2"}]
end
```
then run [`mix deps.get`](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix).

## CONFIGURATION

You can set a default currency and global formatting preferences as follows:

```elixir
config :money,
  default_currency: :EUR,
  separator: ".",
  delimeter: ",",
  fractional_unit: true
  symbol: false,
  symbol_on_right: false,
  symbol_space: false
```

Then you don’t have to specify the currency. Also other config options will apply by default to all conversions.

```elixir
iex> amount = Money.new(1_234_50)
%Money{amount: 123450, currency: :EUR}
iex> Money.to_string(amount)
"1.234,50"
```

You can also pass formatting options to the `to_string` function.
Here is another example of formatting money:

```elixir
iex> amount = Money.new(1_234_50)
%Money{amount: 123450, currency: :EUR}
iex> Money.to_string(amount, symbol: true, symbol_on_right: true, symbol_space: true)
"1.234,50 €"
```

### Currency configuration
Sometimes you will need to setup different formatting options for each currency. You can do so by creating different
configuration for each currency you need to be applied on.
If some options are not found for the currency, it will fallback then to global and default options.

```elixir
config :money, :EUR
  separator: "_",
  symbol: true,
  symbol_on_right: true,
  symbol_space: true
```

Then:

```elixir
iex> amount = Money.new(1_234_50)
%Money{amount: 123450, currency: :EUR}
iex> Money.to_string(amount)
"1_234,50 €"
```

Of course, you can override this options on the `to_string` function when called:

```elixir
iex> amount = Money.new(1_234_50)
%Money{amount: 123450, currency: :EUR}
iex> Money.to_string(amount, symbol: true, symbol_on_right: false, symbol_space: false)
"€1_234,50"
```

## LICENSE

MIT License please see the [LICENSE](./LICENSE) file.
