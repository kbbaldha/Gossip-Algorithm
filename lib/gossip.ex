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
    # if(cur_node_id == 1) do
    #   lst = [cur_node_id + 1|lst]
    
    # else if(cur_node_id == total_nodes) do
    #   lst = [cur_node_id - 1| lst]
    
    # else do
    #   lst = [cur_node_id+1|lst]
    #   lst = [cur_node_id-1|lst]
    # end

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
    # if(column_number == 0) do ## last column
    #    lst = [cur_node_id - 1|lst]
    
    # else if(column_number == 1)  
    #    lst = [cur_node_id+1|lst]
    
    # else 
    #   lst = [cur_node_id - 1|lst]
    #   lst = [cur_node_id + 1|lst]
    # end
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
    IO.inspect state
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
    #state = build_mesh_topology(map)
    state = build_2D_topology(map)
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
