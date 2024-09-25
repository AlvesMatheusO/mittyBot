defmodule MittyBotTest do
  use ExUnit.Case
  doctest MittyBot

  test "greets the world" do
    assert MittyBot.hello() == :world
  end
end
