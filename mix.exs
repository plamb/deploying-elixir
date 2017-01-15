defmodule SamplePlugApp.Mixfile do
  use Mix.Project

  def project do
    [app: :sample_plug_app,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :cowboy, :plug],
     mod: {SamplePlugApp, []}]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.3"},
      {:distillery, "~> 1.1.0"}
    ]
  end
end
