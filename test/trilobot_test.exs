defmodule TrilobotTest do
  use ExUnit.Case
  doctest Trilobot

  test "greets the world" do
    assert Trilobot.hello() == :world
  end
end
