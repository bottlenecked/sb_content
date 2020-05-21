defmodule State.MixProject do
  use Mix.Project

  def project do
    [
      app: :state,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {State.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telemetry, "~>0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~>0.5"},
      {:model, path: "../model"},
      {:geneity, path: "../geneity"},
      {:diff_engine, path: "../diff_engine"},
      {:utils, path: "../utils"}
    ]
  end
end
