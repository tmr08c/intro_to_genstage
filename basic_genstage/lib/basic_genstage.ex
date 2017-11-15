defmodule BasicGenstage do
  @moduledoc """
  Basic example of using a single Producer and single Consumer 
  with GenStage.
  """

  @doc """
  Start a basic Producer-Consumer example of GenStage.

  We create one producer and initialize its state with a list of 20
  and one consumer.
  

  ## Examples

      iex> BasicGenstage.go

  """
  def go do
    things_to_process =
      (1..20)
      |> Enum.to_list()

    {:ok, producer} = GenStage.start_link(Producer, things_to_process)
    {:ok, consumer} = GenStage.start_link(Consumer, :no_state)

    # Here we tell `consumer` to subscribe to request elements from `producer`
    GenStage.sync_subscribe(consumer, to: producer, max_demand: 4)
  end
end

defmodule Producer do
  @moduledoc """
  A simple GenStage Producer stage.
  """
  use GenStage

  def init(things_to_produce) do
    {:producer, things_to_produce}
  end

  @doc """
  `handle_demand` is the callback Producers must implement 

  The first argument is the `demand`, the number of "things" the consumer is requesting; in this case, the number of elements from the list 
  """
  def handle_demand(demand, state)  do
    IO.puts("Producer - #{demand} of my #{length(state)} elements requested.")

    # The events to emit is the second element of the tuple,
    # the third being the state.
    {produced, leftover} = Enum.split(state, demand)
    IO.puts("Producer - Sending #{demand} items (#{inspect(produced, charlists: :as_lists)}) Have #{length(leftover)} left.")

    # must return a list
    {:noreply, produced, leftover}
  end
end

defmodule Consumer do
  @moduledoc """
  A simple GenStage Producer stage.
  """
  use GenStage

  def init(_) do
    {:consumer, :no_state}
  end

  @doc """
  `handle_events` is the callback Consumers must implement 

  Arguments:

  - `events` - a list of "things" that have been requested to consume
  - `from` - the producer(?)
  - `state` - in this case we have set the state to `:no_state` in `init`
  """
  def handle_events(events, _from, state) do
    # Sleep so it looks like we are doing more things 
    :timer.sleep(1000)

    # Print events to terminal.
    IO.puts("Consumer - Received #{length(events)} events - #{inspect(events, charlists: :as_lists)}")

    # We are a consumer, so we never emit events.
    {:noreply, [], state}
  end
end
