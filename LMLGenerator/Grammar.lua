local GL = require('../LMLGenerator/GrammarLib')
local Node = require('../LMLGenerator/Node')

Grammar = 
{
  { -- Rule 01: o1 -> o1-o2
    
    --weight = 1, -- not used for now
    --arity = 1, -- not used for now
    
    --- Cureently takes one node and returns nil if rule can't be applied, and list of nodes that matches otherwise
    IsApplicable = function (node) -- todo change for table of nodes of size #arity
      
      io.write ('Prod 1: '..node:Label()..'  ->  ')
      return {node}
    end,
    
    --- Takes list of applicable nodes, id of next node is should create, and modifies the graph
    ComputeEffect = function (preconditions, nextid)
      local node = preconditions[1]
      
      local lower, higher = GL.SplitByOnePivot(node)
      local remain, go = GL.SplitFeaturesGreedy(node.features, higher)
      
      local newnode = Node:New()
      
      node.zones = lower
      node.features = remain
      node.edges[#node.edges+1] = newnode
      
      newnode.id = nextid
      newnode.zones = higher
      newnode.features = go
      newnode.edges = {node}
      
      io.write (node:Label()..' + '..newnode:Label()..'\n')
      
      return {node, newnode}
    end
  },
  
  
  { -- Rule 02:           o1 [-] o2
    --          o1-02 ->    \   /
    --                       o3
    
    --weight = 1,
    --arity = 1,
    
    IsApplicable = function (node) -- todo change for table of nodes of size #arity
      
      for _, i in ipairs(GL.ShuffleIndexes(node.edges)) do
        local n = node.edges[i]
        -- todo check different id's
        if node.id ~= n.id and n.zones[1].zlevel >= node.zones[1].zlevel then -- assume zones are sorted
          io.write ('Prod 2: '..node:Label()..' + '..n:Label()..'  ->  ')
          return {node, n}
        end
      end

      return nil
    end,
    
    ComputeEffect = function (preconditions, nextid)
      local node1 = preconditions[1]
      local node2 = preconditions[2]
      
      local lower, middle, higher = GL.SplitByTwoPivots(node1, node2)
      
      
      local remain1, go1 = GL.SplitFeaturesGreedy(node1.features, middle)
      local remain2, go2 = GL.SplitFeaturesGreedy(node2.features, middle)
      
      
      
      local newnode = Node:New()
      
      node1.zones = lower
      node1.features = remain1
      node1.edges[#node1.edges+1] = newnode
      
      node2.zones = higher
      node2.features = remain2
      node2.edges[#node2.edges+1] = newnode
      
      newnode.id = nextid
      newnode.zones = middle
      newnode.features = go1
      for i=1,#go2 do newnode.features[#newnode.features+1] = go2[i] end
      newnode.edges = {node1, node2}
      
      
      ---[[ -- random remove edge between node1 and node2 (50%)
      if math.random() < 0.5 then
        node1:RemoveEdge(node2)
        io.write (node1:Label()..' (+) '..node2:Label()..' + '..newnode:Label()..'\n')
      else
        io.write (node1:Label()..' + '..node2:Label()..' + '..newnode:Label()..'\n')
      end
      --]]
      
      io.write (node1:Label()..' + '..node2:Label()..' + '..newnode:Label()..'\n')
      return {node1, node2, newnode}
    end
  }
  

}



return Grammar
