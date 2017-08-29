defmodule AbsintheThrottle.Mixfile do
  use Mix.Project

  def project do
    [
      app: :absinthe_throttle,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.3"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:poolboy, "~> 1.5", optional: true},
      {:semaphore, "~> 1.0", optional: true},
    ]
  end
end
