#
# This file is part of Cyanide.
#
# Copyright 2019 Ispirata Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Cyanide.MixProject do
  use Mix.Project

  def project do
    [
      app: :cyanide,
      version: "1.0.0",
      elixir: "~> 1.6",
      deps: deps(),
      package: package(),
      source_url: "https://github.com/ispirata/cyanide",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.9.1", only: :test},
      {:dialyxir, "== 0.5.1", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: "An Elixir BSON encoding/decoding library.",
      maintainers: ["Davide Bettio", "Riccardo Binetti"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/ispirata/cyanide",
        "Documentation" => "http://hexdocs.pm/cyanide/"
      }
    ]
  end
end
