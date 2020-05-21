defmodule Geneity.MixProject do
  use Mix.Project

  def project do
    [
      app: :geneity,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Geneity.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:model, path: "../model"},
      {:utils, path: "../utils"},
      {:saxy, "~> 1.1"},
      {:freshness, "~> 0.3"}
    ]
  end
end
