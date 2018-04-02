defmodule GameServerTest do
  use ExUnit.Case, async: true

  doctest Bingo.GameServer

  alias Bingo.{GameServer, Game, Player}

  test "spawning a game server process" do
    game_name = generate_game_name()
    size = 3

    assert {:ok, _pid} = GameServer.start_link(game_name, size)
  end

  test "a game process is registered under a unique name" do
    game_name = generate_game_name()
    size = 3

    assert {:ok, _pid} = GameServer.start_link(game_name, size)

    assert {:error, _reason} = GameServer.start_link(game_name, size)
  end

  test "getting a summary" do
    game_name = generate_game_name()
    size = 3

    {:ok, _pid} = GameServer.start_link(game_name, size)

    summary = GameServer.summary(game_name)

    assert Enum.count(summary.squares) == size
    assert summary.scores == %{}
    assert summary.winner == nil
  end

  test "marking squares" do
    game_name = generate_game_name()

    {:ok, _pid} = GameServer.start_link(game_name, 3)

    summary = GameServer.summary(game_name)

    square_1 = square_at_position(summary.squares, 0, 0)
    square_2 = square_at_position(summary.squares, 0, 1)
    square_3 = square_at_position(summary.squares, 0, 2)

    player = Player.new("Nicole", "green")

    _summary = GameServer.mark(game_name, square_1.phrase, player)
    _summary = GameServer.mark(game_name, square_2.phrase, player)
    summary  = GameServer.mark(game_name, square_3.phrase, player)

    assert Map.get(summary.scores, player.name)
    assert summary.winner == player
  end

  test "stores initial state in ETS when started" do
    game_name = generate_game_name()

    {:ok, _pid} = 
      GameServer.start_link(game_name, 3)

    assert [{^game_name, game}] = :ets.lookup(:games_table, game_name)

    assert Enum.count(game.squares) == 3
    assert game.scores == %{}
    assert game.winner == nil
  end

  test "gets its initial state from ETS if previously stored" do

    game_name = generate_game_name()

    player = Player.new("Nicole", "green")

    game = Game.new(3)
    square = square_at_position(game.squares, 0, 0)
    game = Game.mark(game, square.phrase, player)

    :ets.insert(:games_table, {game_name, game})

    {:ok, _pid} = 
      GameServer.start_link(game_name, 3)

    summary = GameServer.summary(game_name)

    square = square_at_position(summary.squares, 0, 0)

    assert square.marked_by == player
  end

  test "updates state in ETS when square is marked" do
    game_name = generate_game_name()

    {:ok, _pid} = 
      GameServer.start_link(game_name, 3)

    summary = GameServer.summary(game_name)

    square = square_at_position(summary.squares, 0, 0)

    player = Player.new("Nicole", "green")

    GameServer.mark(game_name, square.phrase, player)

    assert [{^game_name, game}] = :ets.lookup(:games_table, game_name)

    marked_square = square_at_position(game.squares, 0, 0)

    assert marked_square.marked_by == player
  end

  describe "game_pid" do
    test "returns a PID if it has been registered" do
      game_name = generate_game_name()

      {:ok, pid} = GameServer.start_link(game_name, 3)
      
      assert ^pid = GameServer.game_pid(game_name)
    end

    test "returns nil if the game does not exist" do
      refute GameServer.game_pid("nonexistent-game")
    end
  end

  defp generate_game_name do
    "game-#{:rand.uniform(1_000_000)}"
  end

  defp square_at_position(squares, row, col) do
    squares
    |> Enum.at(row)
    |> Enum.at(col)
  end
end
