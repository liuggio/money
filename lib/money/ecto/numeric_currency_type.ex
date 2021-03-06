if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.NumericCurrency.Type do
    @moduledoc """
    Provides a type for Ecto to store a currency.
    The underlying data type is a integer.

    ## Migration

        create table(:my_table) do
          add :currency, :integer
        end

    ## Schema

        schema "my_table" do
          field :currency, Money.Ecto.NumericCurrency.Type
        end

    """

    alias Money.Currency

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @spec type :: :integer
    def type, do: :integer

    @spec cast(Money.t() | String.t() | atom() | integer()) :: {:ok, atom()} | :error
    def cast(%Money{currency: currency}) when is_binary(currency) or is_atom(currency),
      do: cast(currency)

    def cast(currency) when is_binary(currency) or is_atom(currency) do
      {:ok, Currency.to_atom(currency)}
    rescue
      _ -> :error
    end

    def cast(currency) when is_integer(currency) do
      if Currency.exists?(currency), do: {:ok, Currency.to_atom(currency)}, else: :error
    end

    def cast(_), do: :error

    @spec load(integer()) :: {:ok, atom()}
    def load(int) when is_integer(int), do: {:ok, Currency.to_atom(int)}

    @spec dump(atom()) :: {:ok, integer()}
    def dump(atom) when is_atom(atom), do: {:ok, Currency.number(atom)}
    def dump(_), do: :error
  end
end
