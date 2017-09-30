defmodule MAINTest do
  use ExUnit.Case
  doctest MAIN

  test "greets the world" do
    assert MAIN.hello() == :world
  end
end
