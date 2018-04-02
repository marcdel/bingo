defmodule BingoCheckerTest do
  use ExUnit.Case, async: true

  doctest Bingo.BingoChecker

  alias Bingo.{BingoChecker, Player, Square}

  describe "bingo?/1" do
    
    test "no squares marked" do
      squares = [
        [sq(:a), sq(:b), sq(:c)],
        [sq(:d), sq(:e), sq(:f)],
        [sq(:g), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "row not fully marked" do
      player = Player.new("A", "red")

      squares = [
        [sq(:a, player), sq(:b, player), sq(:c)],
        [sq(:d), sq(:e), sq(:f)],
        [sq(:g), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "column not fully marked" do
      player = Player.new("A", "red")

      squares = [
        [sq(:a, player), sq(:b), sq(:c)],
        [sq(:d, player), sq(:e), sq(:f)],
        [sq(:g), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "left diagonal not fully marked" do
      player = Player.new("A", "red")

      squares = [
        [sq(:a, player), sq(:b), sq(:c)],
        [sq(:d), sq(:e, player), sq(:f)],
        [sq(:g), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "right diagonal not fully marked" do
      player = Player.new("A", "red")

      squares = [
        [sq(:a), sq(:b), sq(:c, player)],
        [sq(:d), sq(:e, player), sq(:f)],
        [sq(:g), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "row marked by different players" do
      player_1 = Player.new("A", "red")
      player_2 = Player.new("B", "blue")

      squares = [
        [sq(:a, player_1), sq(:b, player_2), sq(:c, player_2)],
        [sq(:d), sq(:e), sq(:f)],
        [sq(:g), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "column marked by different players" do
      player_1 = Player.new("A", "red")
      player_2 = Player.new("B", "blue")

      squares = [
        [sq(:a, player_1), sq(:b), sq(:c)],
        [sq(:d, player_1), sq(:e), sq(:f)],
        [sq(:g, player_2), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "left diagonal marked by different players" do
      player_1 = Player.new("A", "red")
      player_2 = Player.new("B", "blue")

      squares = [
        [sq(:a, player_1), sq(:b), sq(:c)],
        [sq(:d), sq(:e, player_1), sq(:f)],
        [sq(:g), sq(:g), sq(:i, player_2)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "right diagonal marked by different players" do
      player_1 = Player.new("A", "red")
      player_2 = Player.new("B", "blue")

      squares = [
        [sq(:a), sq(:b), sq(:c, player_1)],
        [sq(:d), sq(:e, player_1), sq(:f)],
        [sq(:g, player_2), sq(:g), sq(:i)]
      ]

      refute BingoChecker.bingo?(squares)
    end

    test "row bingo" do
      player = Player.new("A", "red")
      
      squares = [
        [sq(:a, player), sq(:b, player), sq(:c, player)],
        [sq(:d), sq(:e), sq(:f)],
        [sq(:g), sq(:g), sq(:i)]
      ]

      assert BingoChecker.bingo?(squares)
    end

    test "column bingo" do
      player = Player.new("A", "red")

      squares = [
        [sq(:a, player), sq(:b), sq(:c)],
        [sq(:d, player), sq(:e), sq(:f)],
        [sq(:g, player), sq(:g), sq(:i)]
      ]

      assert BingoChecker.bingo?(squares)
    end

    test "left diagonal bingo" do
      player = Player.new("A", "red")

      squares = [
        [sq(:a, player), sq(:b), sq(:c)],
        [sq(:d), sq(:e, player), sq(:f)],
        [sq(:g), sq(:g), sq(:i, player)]
      ]

      assert BingoChecker.bingo?(squares)
    end

    test "right diagonal bingo" do
      player = Player.new("A", "red")

      squares = [
        [sq(:a), sq(:b), sq(:c, player)],
        [sq(:d), sq(:e, player), sq(:f)],
        [sq(:g, player), sq(:g), sq(:i)]
      ]

      assert BingoChecker.bingo?(squares)
    end
  end

  test "possible_winning_square_sequences/1" do
    squares = [
      [sq(:a), sq(:b), sq(:c)],
      [sq(:d), sq(:e), sq(:f)],
      [sq(:g), sq(:g), sq(:i)]
    ]
    
    assert BingoChecker.possible_winning_square_sequences(squares) ==
      [
        [sq(:a), sq(:b), sq(:c)], # rows
        [sq(:d), sq(:e), sq(:f)],
        [sq(:g), sq(:g), sq(:i)],

        [sq(:a), sq(:d), sq(:g)], # columns
        [sq(:b), sq(:e), sq(:g)],
        [sq(:c), sq(:f), sq(:i)],

        [sq(:a), sq(:e), sq(:i)], # left diagonal

        [sq(:c), sq(:e), sq(:g)]  # right diagonal
      ]
  end

  test "sequences_with_at_least_one_square_marked/1" do
    player_1 = Player.new("A", "red")
    player_2 = Player.new("B", "blue")

    squares = [
      [sq(:a, player_1), sq(:b, nil),      sq(:c, nil)],
      [sq(:d, nil),      sq(:e, nil),      sq(:f, nil)],
      [sq(:g, player_2), sq(:g, player_1), sq(:i, player_2)]
    ]
    
    assert BingoChecker.sequences_with_at_least_one_square_marked(squares) ==
      [
        [sq(:a, player_1), sq(:b, nil),      sq(:c, nil)],
        [sq(:g, player_2), sq(:g, player_1), sq(:i, player_2)]
      ]
  end

  test "all_squares_marked_by_same_player?/1" do
    player_1 = Player.new("A", "red")
    player_2 = Player.new("B", "blue")

    squares = 
      [sq(:a, player_1), sq(:b, nil), sq(:c, nil)]
    
    refute BingoChecker.all_squares_marked_by_same_player?(squares)

    squares = 
      [sq(:a, player_1), sq(:b, player_1), sq(:c, player_2)]
    
    refute BingoChecker.all_squares_marked_by_same_player?(squares)

    squares = 
      [sq(:a, player_1), sq(:b, player_1), sq(:c, player_1)]
    
    assert BingoChecker.all_squares_marked_by_same_player?(squares)
  end

  defp sq(phrase, marked_by \\ nil) do
    %Square{phrase: phrase, points: 10, marked_by: marked_by}
  end

end
