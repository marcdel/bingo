defmodule Bingo.GameDisplay do
  @moduledoc """
  Displays a textual representation of a game.

  Note: Only standard colors are supported.
  """

  alias IO.ANSI

  @doc """
  Prints a textual representation of the game to standard out.
  """
  def display(game) do
    print_squares(game.squares)
    print_scores(game.scores)
    print_bingo(game)
  end

  defp print_squares(squares) do
    IO.write("\n")

    column_width = column_width(squares)

    Enum.each(squares, fn row_squares ->
      print_row(row_squares, column_width)
    end)
  end

  defp print_row(squares, column_width) do
    squares
    |> Enum.map_join(" |  ", &square_in_ansi_format(&1, column_width))
    |> IO.puts()
  end

  defp square_in_ansi_format(square, column_width) do
    [color_of_square(square), text_in_square_padded(square, column_width)]
    |> ANSI.format(true)
    |> IO.chardata_to_string()
  end

  defp color_of_square(square) do
    case square.marked_by do
      nil    -> ANSI.normal()
      player -> String.to_atom(player.color)
    end
  end

  defp text_in_square_padded(square, column_width) do
    square
    |> text_in_square()
    |> String.pad_trailing(column_width)
  end

  defp text_in_square(square) do
    "#{square.phrase} (#{square.points})"
  end

  defp column_width(squares) do
    squares
    |> List.flatten()
    |> Enum.map(&text_in_square/1)
    |> Enum.map(&String.length/1)
    |> Enum.max()
  end

  defp print_scores(scores) do
    IO.write("\n")

    scores
    |> (&"Scores: #{inspect(&1)}").()
    |> IO.puts()
  end

  defp print_bingo(game) do
    IO.write("\n")

    status =
      case game.winner do
        nil    -> " 🙁  No Bingo (yet) "
        player -> " ⭐️  BINGO! #{player.name} wins!"
      end

    IO.puts([ANSI.inverse(), status, ANSI.reset()])

    IO.write("\n")
  end
end
