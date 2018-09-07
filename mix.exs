defmodule Money.Mixfile do
  use Mix.Project

  @version "1.2.2"
  @github_url "https://github.com/liuggio/money"

  def project do
    [app: :money,
     name: "Money",
     version: @version,
     elixir: "~> 1.0",
     deps: deps(),
     source_url: "https://github.com/liuggio/money",
     docs: fn ->
       [source_ref: "v#{@version}",
        canonical: "http://hexdocs.pm/money",
        main: "Money",
        source_url: @github_url,
        extras: ["README.md", "CONTRIBUTING.md"]
       ]
     end,
     description: description(),
     package: package()]
  end

  def application do
    []
  end

  defp deps do
    [
      # Soft dependencies
      {:ecto, "~> 1.0 or ~> 2.0 or ~> 2.1", optional: true},
      {:phoenix_html, "~> 2.0", optional: true},

      # Code style
      {:credo, "~> 0.5", only: [:dev, :test]},

      # Docs
      {:ex_doc, "~> 0.14", only: [:dev, :docs]},
    ]
  end

  defp description do
    """
    Elixir library for working with Money safer, easier, and fun, is an interpretation of the Fowler's Money pattern in fun.prog.
    """
  end

  defp package do
    [
     maintainers: ["Giulio De Donato", "Andrew Timberlake"],
     contributors: ["Giulio De Donato", "Andrew Timberlake"],
     licenses: ["MIT"],
     links: %{"GitHub" => @github_url}]
  end
end
