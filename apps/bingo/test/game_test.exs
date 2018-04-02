defmodule GameTest do
  use ExUnit.Case, async: true

  doctest Bingo.Game

  alias Bingo.{Game, Player, Square, Buzzwords}

  setup do
    [
      player_1: Player.new("Nicole", "green"),
      player_2: Player.new("Mike", "blue"),
      
      # Grid of squares with preset buzzwords (letters) 
      # so the tests are consistent.
      squares: [
        [sq("A", 10), sq("B", 20), sq("C", 30)],
        [sq("D", 10), sq("E", 20), sq("F", 30)],
        [sq("G", 10), sq("H", 20), sq("I", 30)]
      ]
    ]
  end

  describe "creating a game" do

    test "with a list of buzzwords and a size" do
      game = Game.new(Buzzwords.read_buzzwords(), 3)

      assert_game_size game, 3
    end

    test "with a size" do
      game = Game.new(3)

      assert_game_size game, 3
    end

    defp assert_game_size(game, size) do
      row_count = Enum.count(game.squares)

      assert row_count == size

      first_row = Enum.at(game.squares, 0)

      column_count = Enum.count(first_row)

      assert column_count == row_count

      assert %Square{} = Enum.at(first_row, 0)
    end
  end

  # PWS = Possible Winning Sequence (row, column, diagonal)

  describe "no winner when PWS not fully marked" do
    
    test "no winner when row isn't fully marked", context do
      game = 
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("B", context.player_1)

      assert game.winner == nil
    end

    test "no winner when column isn't fully marked", context do
      game = 
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("D", context.player_1)

      assert game.winner == nil
    end

    test "no winner when left diagonal isn't fully marked", context do
      game = 
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("E", context.player_1)

      assert game.winner == nil
    end

    test "no winner when right diagonal isn't fully marked", context do
      game = 
        new_game(context.squares)
        |> Game.mark("C", context.player_1)
        |> Game.mark("E", context.player_1)
      
      assert game.winner == nil
    end
  end

  describe "no winner when PWS fully marked, but by different players" do

    test "no winner when row is fully marked by different players", context do
      game =
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("B", context.player_2)
        |> Game.mark("C", context.player_1)

      assert game.winner == nil
    end

    test "no winner when column is fully marked by different players", 
      context do

      game =
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("D", context.player_1)
        |> Game.mark("G", context.player_2)

      assert game.winner == nil
    end


    test "no winner when left diagonal is fully marked by different players", 
      context do
      
      game =
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("E", context.player_2)
        |> Game.mark("I", context.player_1)

      assert game.winner == nil
    end

    test "no winner when right diagonal is fully marked by different players", 
      context do
      
      game =
        new_game(context.squares)
        |> Game.mark("C", context.player_1)
        |> Game.mark("E", context.player_2)
        |> Game.mark("G", context.player_1)

      assert game.winner == nil
    end
  end

  describe "winner when PWS fully marked by same player" do

    test "winner when row is fully marked by same player", 
      context do
      
      game =
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("B", context.player_1)
        |> Game.mark("C", context.player_1)

      assert game.winner == context.player_1
    end

    test "winner when column is fully marked by same player", 
      context do

      game =
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("D", context.player_1)
        |> Game.mark("G", context.player_1)

      assert game.winner == context.player_1
    end

    test "winner when left diagonal is fully marked by same player",
      context do

      game =
        new_game(context.squares)
        |> Game.mark("A", context.player_1)
        |> Game.mark("E", context.player_1)
        |> Game.mark("I", context.player_1)

      assert game.winner == context.player_1
    end

    test "winner when right diagonal is fully marked by same player", 
      context do

      game =
        new_game(context.squares)
        |> Game.mark("C", context.player_1)
        |> Game.mark("E", context.player_1)
        |> Game.mark("G", context.player_1)

      assert game.winner == context.player_1
    end
  end

  test "marking squares updates the scores", context do
    game =
      new_game(context.squares)
      |> Game.mark("A", context.player_1)
      |> Game.mark("B", context.player_1)
      |> Game.mark("H", context.player_2)
      |> Game.mark("I", context.player_2)

    assert game.scores == %{"Nicole" => 30, "Mike" => 50}
  end

  # Convenience for creating a square. Short function
  # name makes the grid visually easier to parse.
  defp sq(phrase, points) do
    Square.new(phrase, points)
  end

  defp new_game(squares) do
    %Game{squares: squares}
  end
end
