defmodule Soundcloud.Mixfile do
  use Mix.Project

  def project do
    [
      app: :soundcloud,
      version: "0.1.0",
      mame: "Soundcloud",
      description: "A Soundcloud API wrapper.",
      source_url: "https://github.com/adolfosilva/soundcloud",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      build_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {Soundcloud.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README", "LICENSE"],
      maintainers: ["Adolfo Silva"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/adolfosilva/soundcloud"}
    ]
  end
end
