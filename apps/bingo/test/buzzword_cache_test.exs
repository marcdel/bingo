defmodule BuzzwordCacheTest do
  use ExUnit.Case, async: true

  doctest Bingo.BuzzwordCache

  alias Bingo.BuzzwordCache

  test "getting the cached buzzwords" do
    buzzwords = BuzzwordCache.get_buzzwords()

    assert %{phrase: _, points: _} = List.first(buzzwords)
  end

end
