defmodule CyanideTest do
  use ExUnit.Case
  doctest Cyanide

  test "greets the world" do
    assert Cyanide.hello() == :world
  end
end
