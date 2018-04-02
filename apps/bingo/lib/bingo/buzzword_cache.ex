defmodule Bingo.BuzzwordCache do
  @moduledoc """
  A process that loads a collection of buzzwords from an external source
  and caches them for expedient access. The cache is automatically 
  refreshed every hour.
  """

  use GenServer

  @refresh_interval :timer.minutes(60)

  # Client (Public) Interface

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_buzzwords() do
    GenServer.call(__MODULE__, :get_buzzwords)
  end

  # Server Callbacks

  def init(:ok) do
    state = load_buzzwords()
    schedule_refresh()
    {:ok, state}
  end

  def handle_call(:get_buzzwords, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, _state) do
    state = load_buzzwords()
    schedule_refresh()
    {:noreply, state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)    
  end

  # Loads buzzwords from a CSV file, though you could load
  # them from any source, such as an external API.
  defp load_buzzwords() do
    Bingo.Buzzwords.read_buzzwords()
  end
end
