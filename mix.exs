defmodule Bson.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cyanide,
      name: "Cyanide",
      version: "0.5.0",
      elixir: "~> 1.4",
      description: "BSON implementation for Elixir",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ],
      deps: deps(),
      package: package(),
      source_url: "https://github.com/ispirata/cyanide",
      docs: [main: "Cyanide"]
    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7.3", only: :test}
    ]
  end

  defp package do
    [
      description: "An Elixir BSON encoding/decoding library.",
      maintainers: ["Davide Bettio", "Riccardo Binetti"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ispirata/cyanide",
        "Documentation" => "http://hexdocs.pm/cyanide/"
      }
    ]
  end
end
