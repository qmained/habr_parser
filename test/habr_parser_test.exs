defmodule HabrParserTest do
  use ExUnit.Case
  doctest HabrParser

  test "greets the world" do
    assert HabrParser.hello() == :world
  end
end
