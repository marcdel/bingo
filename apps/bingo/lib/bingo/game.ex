defmodule Bingo.Game do

  @enforce_keys [:squares]
  defstruct squares: nil, scores: %{}, winner: nil

  alias Bingo.{Buzzwords, Game, Square, BingoChecker}

  @doc """
  Creates a game with a `size` x `size` collection of squares 
  taken randomly from the given list of `buzzwords` where
  each buzzword is of the form `%{phrase: "Upsell", points: 10}`.
  """
  def new(size) when is_integer(size) do
    buzzwords = Buzzwords.read_buzzwords()
    Game.new(buzzwords, size)
  end

  @doc """
  Creates a game with a `size` x `size` collection of squares 
  taken randomly from the given list of `buzzwords` where
  each buzzword is of the form `%{phrase: "Upsell", points: 10}`.
  """
  def new(buzzwords, size) do
    squares = 
      buzzwords
      |> Enum.shuffle()
      |> Enum.take(size * size)
      |> Enum.map(&Square.from_buzzword(&1))
      |> Enum.chunk_every(size)

    %Game{squares: squares}
  end

  @doc """
  Marks the square that has the given `phrase` for the given `player`,
  updates the scores, and checks for a bingo!
  """
  def mark(game, phrase, player) do
    game
    |> update_squares_with_mark(phrase, player)
    |> update_scores()
    |> assign_winner_if_bingo(player)
  end

  defp update_squares_with_mark(game, phrase, player) do
    new_squares =
      game.squares
      |> List.flatten()
      |> Enum.map(&mark_square_having_phrase(&1, phrase, player))
      |> Enum.chunk_every(Enum.count(game.squares))

    %{game | squares: new_squares}
  end

  defp mark_square_having_phrase(square, phrase, player) do
    case square.phrase == phrase do
      true -> %Square{square | marked_by: player}
      false -> square
    end
  end

  defp update_scores(game) do
    scores =
      game.squares
      |> List.flatten()
      |> Enum.reject(&is_nil(&1.marked_by))
      |> Enum.map(fn s -> {s.marked_by.name, s.points} end)
      |> Enum.reduce(%{}, fn {name, points}, scores ->
        Map.update(scores, name, points, &(&1 + points))
      end)

    %{game | scores: scores}
  end

  defp assign_winner_if_bingo(game, player) do
    case BingoChecker.bingo?(game.squares) do
      true  -> %{game | winner: player}
      false -> game
    end
  end
end
