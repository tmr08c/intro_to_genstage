* Producer / ProducerConsumer / Consumer 
** Producer and Consumers

   Our ~Producer~ and ~Consumer~ are much the same as before. 

   See our previous example's section on [[*Producer][Producer]] and [[*Consumer][Consumer]] for more information about them.

** ProducerConsumer

  #+BEGIN_SRC elixir
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
    IO.puts("ProducerConsumer - Received #{length(events)} events - #{inspect(events)}")

    # Do the doubling
    events = Enum.map(events , &(&1 * 2))

    # Print events to terminal.
    IO.puts("ProducerConsumer - Doubles each element, now producing #{inspect(events)}")

    {:noreply, events, :no_state}
  end
end
  #+END_SRC
 
*** [[https://hexdocs.pm/gen_stage/GenStage.html#c:init/1][~init/1~]]

    - Again, we aren't worried about state, so we set an initial state of ~:no_state~ to indicate this
    - Like in our ~Producer~ and our ~Consumer~ we return a tuple with the first element denoting our stage type, and te second element setting our state. This time, we set our stage type to ~:producer_consumer~

*** [[https://hexdocs.pm/gen_stage/GenStage.html#c:handle_events/3][~handle_events/3]] 

    Siimlar to a ~Consumer~, we implement a ~handle_events~ callback. We do not need to implment a ~handle_demand~ callback because ~handle_events~ with return a tuple that includes events for the next stage.

**** Function Agruments 

     - ~events~ - a list of "things" that have been requested to consume
     - ~from~ 
       - The term that identifies a subscription associated with the corresponding producer/consumer, of the form ~{pid, subscription_tag}~
       - In this example, we aren't worried about the ~_from~, so we prefix it with an ~_~ to indiciate it is uused.
     - ~state~ - in this case we have set the state to ~:no_state~ in ~init~

**** What it's doing
      
A ~ProducerConsumer~ does just that, it consumes events and produces new events. Generally, the idea of a ~ProducerConsumer~ is to do some sort of transformation. In our example, each event is a number from a list. We are consuming these numbers, doubling them, and then producing them on to the next stage.

**** Return

     As mentioned earlier, we are returning a tuple that contains events that we can produce to the next stage, ~{:noreply, events, :no_state}~.

     In a ~Consumer~ our second element in the tuple is an empty list (~[]~), indicating that there are no additional events to pass on. In our ~ProducerConsumer~, we have a non-empty list, our list of doubled elements.

** Sample Output

#+BEGIN_SRC elixir
iex(1)> ProducerConsumerExample.go
ProducerConsumerExample.go
Producer - 4 of my 20 elements requested.
Producer - Sending 4 items ([1, 2, 3, 4]) . Have 16 left.
iex(2)> ProducerConsumer - Received 2 events - [1, 2]
iex(2)> ProducerConsumer - Doubles each element, now producing [2, 4]
iex(2)> Producer - 2 of my 16 elements requested.
iex(2)> Producer - Sending 2 items ([5, 6]) . Have 14 left.
iex(2)> Consumer - Received 2 events - [2, 4]
iex(2)> ProducerConsumer - Received 2 events - [3, 4]
iex(2)> ProducerConsumer - Doubles each element, now producing [6, 8]
iex(2)> Producer - 2 of my 14 elements requested.
iex(2)> Producer - Sending 2 items ([7, 8]) . Have 12 left.
iex(2)> ProducerConsumer - Received 2 events - [5, 6]
iex(2)> Consumer - Received 2 events - [6, 8]
iex(2)> ProducerConsumer - Doubles each element, now producing [10, 12]
iex(2)> Producer - 2 of my 12 elements requested.
iex(2)> Producer - Sending 2 items ([9, 10]) . Have 10 left.
iex(2)> ProducerConsumer - Received 2 events - [7, 8]
iex(2)> Consumer - Received 2 events - [10, 12]
iex(2)> ProducerConsumer - Doubles each element, now producing [14, 16]
iex(2)> Producer - 2 of my 10 elements requested.
iex(2)> Producer - Sending 2 items ([11, 12]) . Have 8 left.
iex(2)> ProducerConsumer - Received 2 events - [9, 10]
iex(2)> Consumer - Received 2 events - [14, 16]
iex(2)> ProducerConsumer - Doubles each element, now producing [18, 20]
iex(2)> Producer - 2 of my 8 elements requested.
iex(2)> Producer - Sending 2 items ([13, 14]) . Have 6 left.
iex(2)> ProducerConsumer - Received 2 events - [11, 12]
iex(2)> Consumer - Received 2 events - [18, 20]
iex(2)> ProducerConsumer - Doubles each element, now producing [22, 24]
iex(2)> Producer - 2 of my 6 elements requested.
iex(2)> Producer - Sending 2 items ([15, 16]) . Have 4 left.
iex(2)> ProducerConsumer - Received 2 events - [13, 14]
iex(2)> Consumer - Received 2 events - [22, 24]
iex(2)> ProducerConsumer - Doubles each element, now producing [26, 28]
iex(2)> Producer - 2 of my 4 elements requested.
iex(2)> Producer - Sending 2 items ([17, 18]) . Have 2 left.
iex(2)> ProducerConsumer - Received 2 events - [15, 16]
iex(2)> Consumer - Received 2 events - [26, 28]
iex(2)> ProducerConsumer - Doubles each element, now producing [30, 32]
iex(2)> Producer - 2 of my 2 elements requested.
iex(2)> Producer - Sending 2 items ([19, 20]) . Have 0 left.
iex(2)> ProducerConsumer - Received 2 events - [17, 18]
iex(2)> Consumer - Received 2 events - [30, 32]
iex(2)> ProducerConsumer - Doubles each element, now producing [34, 36]
iex(2)> Producer - 2 of my 0 elements requested.
iex(2)> Producer - Sending 2 items ([]) . Have 0 left.
iex(2)> ProducerConsumer - Received 2 events - [19, 20]
iex(2)> Consumer - Received 2 events - [34, 36]
iex(2)> ProducerConsumer - Doubles each element, now producing [38, 40]
iex(2)> Producer - 2 of my 0 elements requested.
iex(2)> Producer - Sending 2 items ([]) . Have 0 left.
iex(2)> Consumer - Received 2 events - [38, 40]
iex(2)> 
#+END_SRC
