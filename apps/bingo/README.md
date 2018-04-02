# Bingo

## Installation

Add `bingo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bingo, path: "../bingo"}
  ]
end
```

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `bingo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bingo, "~> 0.1.0"}
  ]
end
```

## Public Interface

Here's how to spawn a game server process and play a game from an `iex` session:

1. Spawn a new game server process with the name "icy-sun" and a 3x3 grid of randomly-generated squares:

    ```elixir
    iex> {:ok, pid} = Bingo.GameSupervisor.start_game("icy-sun", 3)
    ```

2. Get a summary of the game:

    ```elixir
    iex> summary = Bingo.GameServer.summary("icy-sun")
    ```

3. Mark the square represented by the phrase "Upsell" by the player (replace "Upsell" with a phrase from your game):

    ```elixir
    iex> player = Bingo.Player.new("Nicole", "green")

    iex> summary = Bingo.GameServer.mark("icy-sun", "Upsell", player)
    ```

4. Print a textual representation of the game:

    ```elixir
    iex> Bingo.GameDisplay.display(summary)
    ```

## Testing

```shell
mix test
```