defmodule MAIN do
  
  def main(args) do
      start_nodes(30)
  end

  def start_nodes(n) when n<1 do
    IO.puts "all nodes created"
    send_message("node_"<>Integer.to_string(5))
  end

  def start_nodes(n) do

    node_name = "node_" <> Integer.to_string(n)
    GenServer.start_link(__MODULE__, [], name: String.to_atom node_name)
    start_nodes(n-1)
  end

  def init(state) do
    {:ok,state}
  end

  def send_message(node_name) do
    GenServer.cast(String.to_atom(node_name), {:send_message, "keyur here"})
  end

  # servwe callbacks

  def handle_cast({:send_message ,new_message},messages) do
  
    IO.puts "got message::"<>new_message  
    IO.inspect self()
    {:no_reply,messages}
  end

end
