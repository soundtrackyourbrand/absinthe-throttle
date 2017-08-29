defmodule AbsintheThrottleTest do
  use ExUnit.Case
  doctest AbsintheThrottle

  test "greets the world" do
    assert AbsintheThrottle.hello() == :world
  end
end
