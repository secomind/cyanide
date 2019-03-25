# Cyanide

Cyanide is a BSON library for Elixir.

## Installation

The package can be installed by adding `cyanide` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cyanide, "~> 1.0"}
  ]
end
```

## Usage

```elixir
Cyanide.encode(%{"value" => 42})
#=> {:ok, <<16, 0, 0, 0, 16, 118, 97, 108, 117, 101, 0, 42, 0, 0, 0, 0>>}

Cyanide.decode(<<16, 0, 0, 0, 16, 118, 97, 108, 117, 101, 0, 42, 0, 0, 0, 0>>)
#=> {:ok, %{"value" => 42}}
```
