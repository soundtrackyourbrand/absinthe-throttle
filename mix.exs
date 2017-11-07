defmodule AbsintheThrottle.Mixfile do
  use Mix.Project

  def project do
    [
      app: :absinthe_throttle,
      version: "0.4.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "absinthe_throttle",
      source_url: "https://github.com/soundtrackyourbrand/absinthe-throttle"
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

  defp description do
    "Pluggable resolve throttling for Absinthe GraphQL."
  end

  defp package do
    [
      name: "absinthe_throttle",
      licenses: ["MIT"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Fredrik Wärnsberg"],
      links: %{"GitHub" => "https://github.com/soundtrackyourbrand/absinthe-throttle"}
    ]
  end
end
