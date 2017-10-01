defmodule MAIN do
  use GenServer
  def main(args) do
      start_nodes(36,36)
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

  def get_mesh_neighbours(node_id,cur_node_id) do
     mesh_list(node_id,cur_node_id,[])
  end

  def build_mesh_topology(state) do
    total_nodes = Map.get(state,"total_nodes")
    cur_node_id = Map.get(state,"id")
    neighbours = get_mesh_neighbours(total_nodes,cur_node_id)
    state = Map.put(state,"neighbours",neighbours)
    #IO.inspect state
    state
  end
  ##end mesh topology


  ## line topology
  
  def get_line_neighbours(total_nodes,cur_node_id) do
    lst = []
    
    cond do
      cur_node_id == 1 -> lst = [cur_node_id + 1|lst]
      cur_node_id == 1 -> lst = [cur_node_id + 1|lst]
      true -> lst = [cur_node_id + 1|lst]
    end

    lst
  end
  
  
  def build_line_topology(state) do
    total_nodes = Map.get(state,"total_nodes")
    cur_node_id = Map.get(state,"id")
    neighbours = get_line_neighbours(total_nodes,cur_node_id)
    state = Map.put(state,"neighbours",neighbours)
    #IO.inspect state
    state
  end


  ## end line topology

  ## 2D grid


  def get_2D_neighbours(dimension,cur_node_id) do
    column_number = round :math.fmod cur_node_id,dimension
    top = cur_node_id - dimension
    lst = [] 
    if(top>0) do
      lst = [top|lst]
    end 
    down = cur_node_id + dimension
    if(down < dimension*dimension) do
      lst = [down|lst]
    end

    # ##side neighbours
   
    cond do
      column_number == 0 -> lst = [cur_node_id - 1|lst]
      column_number == 1 -> lst = [cur_node_id+1|lst]
      true -> lst = [cur_node_id - 1|lst]
              lst = [cur_node_id + 1|lst]
    end
    lst
  end

  def build_2D_topology(state) do
    total_nodes = Map.get(state,"total_nodes")
    dimension = round :math.ceil :math.sqrt(total_nodes)
    total_nodes = dimension*dimension
    Map.put(state,"total_nodes",total_nodes)
    IO.puts "total_nodes :::::" <> Integer.to_string total_nodes
    cur_node_id = Map.get(state,"id")
    neighbours = get_2D_neighbours(dimension,cur_node_id)
    state = Map.put(state,"neighbours",neighbours)
    #IO.inspect state
    state
  end

  ##2D grid ends

  ##imperfect 2D start

  def get_imperfect2D_neighbours(total_nodes,dimension,cur_node_id) do
    
    lst = get_2D_neighbours(dimension,cur_node_id)
    #add random node
    lst = [:rand.uniform(total_nodes)|lst]
    lst
  end

  def build_imperfect2D_topology(state) do
    total_nodes = Map.get(state,"total_nodes")
    dimension = round :math.ceil :math.sqrt(total_nodes)
    total_nodes = dimension*dimension
    Map.put(state,"total_nodes",total_nodes)

    cur_node_id = Map.get(state,"id")
    neighbours = get_imperfect2D_neighbours(total_nodes,dimension,cur_node_id)
    state = Map.put(state,"neighbours",neighbours)
    #IO.inspect state
    state
  end

  ##imperfect 2d end


  def start_nodes(n,total) when n<1 do
    IO.puts "all nodes created"
    ##send_message("node_"<>Integer.to_string(5))
    GenServer.call(String.to_atom("node_"<>Integer.to_string(5)), {:receive_msg, "keyur here"})
    IO.gets ""
  end

  def start_nodes(n,total) do

    node_name = "node_" <> Integer.to_string(n)
    GenServer.start_link(__MODULE__, {n,total}, name: String.to_atom(node_name))
    start_nodes(n-1,total)
  end

  def init(args) do
    #IO.inspect self()
    total_nodes = elem(args,1)
    #node_name = "node_" <> Integer.to_string(elem(args,0))
    node_id = elem(args,0)
    map =  %{"id" => node_id,"total_nodes" => total_nodes, "neighbours" => []}    
    state = build_mesh_topology(map)
    #state = build_2D_topology(map)
    {:ok,state}
  end

  def send_message(neighbours) do

    node_id = Enum.random(neighbours)
    node_name = "node_"<>Integer.to_string(node_id)
    pid  = Process.whereis(String.to_atom(node_name))
    if(pid == nil) do
      send_message(neighbours)
    end
    if(Process.alive?(pid) == true) do
      GenServer.call(String.to_atom(node_name), {:receive_msg, "keyur here"}) 
    end
    :timer.sleep(150)
    send_message(neighbours)
  end

   
  # servwe callbacks

  def handle_call({:send_message ,new_message},_from,state) do  
    IO.puts "got message::"<>new_message  
    IO.inspect self()
    GenServer.call(String.to_atom("node_30"), {:trial, "keyur next node"})
    {:reply,state,state}
  end

  def handle_call({:trial, msg}, _from, state) do
    IO.puts " new msg:"<>msg <> " :: from"
    IO.inspect state
    IO.inspect _from
    IO.inspect self()

    {:reply,state,state}
  end


  def handle_call({:receive_msg, msg},_from,state) do
   # IO.puts "neighbourrrrrrrrrrrrrrrrrrrrrs" 
   # IO.inspect state
     neighbours = Map.get(state,"neighbours")
     #n_length = length(neighbours)
     
     
     if(Map.get(state,"send_msg_process") == nil) do
     
        send_msg_pid = spawn fn -> send_message(neighbours) end 
        state = Map.put(state,"send_msg_process",send_msg_pid)  
        
     end

    if(Map.get(state,"receive_msg_count") == nil) do
     # IO.puts "no keyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
        state = Map.put(state,"receive_msg_count",0)
        #IO.inspect state
    end
    receive_msg_count = Map.get(state,"receive_msg_count")
    #IO.puts "sssssssssssssssss::::::::"
    #IO.puts receive_msg_count
    receive_msg_count = receive_msg_count + 1
    state = Map.put(state,"receive_msg_count",receive_msg_count)

    if(receive_msg_count >= 10) do
      ## Kill process if alive
      IO.puts "kill process :: " <> Integer.to_string(Map.get(state,"id"))
      #Process.exit(Map.get(state,"send_msg_process"), :normal)      
      Process.exit(self(), :normal)      
    end
    #IO.puts "NOde : "<> Integer.to_string(Map.get(state,"id")) <> " received mesg : " <> Integer.to_string(receive_msg_count)
    {:reply,state,state}
  end
  

end
