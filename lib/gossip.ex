defmodule MAIN do
  use GenServer
  def main(args) do
      start_nodes(30,30)
  end

  def mesh_list(node_id,cur_node_id,lst) when node_id<1 do
    lst
  end
## mesh topology
  def mesh_list(node_id,cur_node_id,lst) do
    if(node_id != cur_node_id) do 
      lst = [node_id|lst]
    end
     mesh_list(node_id-1,cur_node_id,lst)
  end

  def build_mesh_topology(state) do
    total_nodes = Map.get(state,"total_nodes")
    cur_node_id = Map.get(state,"id")
 
    
    Map.put(state,"neighbours",[])

    neighbours = mesh_list(total_nodes,cur_node_id,[])
    #IO.inspect neighbours
    
    state = Map.put(state,"neighbours",neighbours)
    #IO.inspect state
    state
  end
  ##end mesh topology


  
  def start_nodes(n,total) when n<1 do
    IO.puts "all nodes created"
    send_message("node_"<>Integer.to_string(10))
    IO.gets ""
  end

  def start_nodes(n,total) do

    node_name = "node_" <> Integer.to_string(n)
    GenServer.start_link(__MODULE__, {n,total}, name: String.to_atom(node_name))
    start_nodes(n-1,total)
  end

  def init(args) do
    IO.inspect self()
    total_nodes = elem(args,1)
    #node_name = "node_" <> Integer.to_string(elem(args,0))
    node_id = elem(args,0)
    map =  %{"id" => node_id,"total_nodes" => total_nodes, "neighbours" => []}    
    state = build_mesh_topology(map)
    {:ok,state}
  end

  def send_message(node_name) do
    GenServer.call(String.to_atom(node_name), {:send_message, "keyur here"})
  end

  # servwe callbacks

  def handle_call({:send_message ,new_message},_from,state) do  
    IO.puts "got message::"<>new_message  
    IO.inspect self()
    GenServer.call(String.to_atom("node_8"), {:trial, "keyur next node"})
    {:reply,state,state}
  end

  def handle_call({:trial, msg}, _from, state) do
    IO.puts " new msg:"<>msg <> " :: from"
    IO.inspect state
    IO.inspect _from
    IO.inspect self()

    {:reply,state,state}
  end

  

end
