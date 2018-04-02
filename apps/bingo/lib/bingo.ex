defmodule Bingo do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Bingo.GameRegistry},
      Bingo.BuzzwordCache,
      Bingo.GameSupervisor
    ]

    :ets.new(:games_table, [:public, :named_table])

    opts = [strategy: :one_for_one, name: Bingo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
