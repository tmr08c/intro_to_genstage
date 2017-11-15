defmodule ProducerConsumerExample do
  @moduledoc """
  A basic GenStage example that contains a Producer, ProducerConsumer, and
  a Consumer
  """

  @doc """
  Start a basic Producer-ProducerConsumer-Consumer example of GenStage.

  We create one producer and initialize its state with a list of 20,
  a ProducerConsumer that will consume events (the list of 20) from the first producer,
  double them, and pass those events down to the final Consumer.

  ## Examples

  iex> ProducerConsumerExample.go

  """
  def go do
    things_to_process =
      (1..20)
      |> Enum.to_list()

    {:ok, producer} = GenStage.start_link(Producer, things_to_process)
    {:ok, producer_consumer} = GenStage.start_link(ProducerConsumer, :no_state)
    {:ok, consumer} = GenStage.start_link(Consumer, :no_state)

    # Here we set up the stages
    # Events will flow from the Producer to the ProducerConsumer
    # and finally to the Consumer
    # `producer` --> `producer_consumer` --> `consumer`

    # `consumer` will request events from `producer_consumer`
    GenStage.sync_subscribe(consumer, to: producer_consumer, max_demand: 4)
    # `producer_consumer` will request from `producer`
    GenStage.sync_subscribe(producer_consumer, to: producer, max_demand: 4)
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
    IO.puts("Producer - Sending #{demand} items (#{inspect(produced, charlists: :as_lists)}) . Have #{length(leftover)} left.")

    # must return a list
    {:noreply, produced, leftover}
  end
end

defmodule ProducerConsumer do
  @moduledoc """
  A GenStage Producer and Consumer.

  It does not need ti implement `handle_demand` because the demand
  is always forwarded from the original `Producer` through `GenStage.sync_subscribe` 
  """
  use GenStage

  def init(:no_state) do
    {:producer_consumer, :no_state}
  end

  def handle_events(events, _from, :no_state) do
    # Sleep so it looks like we are doing more things 
    :timer.sleep(1000)

    # Print events to terminal.
    IO.puts("ProducerConsumer - Received #{length(events)} events - #{inspect(events, charlists: :as_lists)}")

    # Do the doubling
    events = Enum.map(events , &(&1 * 2))

    # Print events to terminal.
    IO.puts("ProducerConsumer - Doubles each element, now producing #{inspect(events, charlists: :as_lists)}")

    {:noreply, events, :no_state}
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
