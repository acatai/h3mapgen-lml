--- Library with heler functions for building grammars
-- @class table
-- @name GrammarLib
local GrammarLib = {} 


--- Makes zones in splitting order, i.e. level-based sorted but Local as minimum (if possible)
-- @param node Node with zones to sort
function GrammarLib.OrderZones(node)
  node:SortZones() 
  -- the local zone have to be the lowest if possible ! (no buffer zones left behind if local zones can be)
  if node.zones[1].ztype ~= 'L' then
    for i=2,#node.zones do
      if node.zones[i].ztype == 'L' then
        node.zones[1], node.zones[i] = node.zones[i], node.zones[1]
        break
      end
    end
  end
  
end


--- Split zones in given node into two lists (i.e. using one pivot)
-- (Watch for not leaving only buffer zones in lower part of the split!)
-- @param node Node to split
-- @return Pair of zones split into lower, higher (both nonempty)
function GrammarLib.SplitByOnePivot(node)

  GrammarLib.OrderZones(node)
  
  local pivot = math.random(#node.zones-1) -- at least one element must go
  
  local lower={}
  local higher={}
  for i=1,pivot do lower[#lower+1] = node.zones[i] end
  for i=pivot+1,#node.zones do higher[#higher+1] = node.zones[i] end

  assert(#lower~=0 and #higher~=0, 'GrammarLib.SplitByOnePivot - empty split')
  return lower, higher

end


--- Split zones in given two nodes into three lists (i.e. using two pivots)
-- (Watch for not leaving only buffer zones in lower part of the split!)
-- @param node1 First node to split 
-- @param node2 Second node to split (have to contain >1 zones)
-- @return Triple of zones split into lower, middle, higher (all nonempty)
function GrammarLib.SplitByTwoPivots(node1, node2)

  GrammarLib.OrderZones(node1)
  GrammarLib.OrderZones(node2)
  
  local pivot1 = math.random(#node1.zones-1) -- at least one element must go
  local pivot2 = math.random(#node2.zones) -- at least one elemnt must stay
  
  local lower={}
  local middle={}
  local higher={}
  for i=1,pivot1 do lower[#lower+1] = node1.zones[i] end
  for i=pivot1+1,#node1.zones do middle[#middle+1] = node1.zones[i] end

  for i=1,pivot2-1 do middle[#middle+1] = node2.zones[i] end
  for i=pivot2,#node2.zones do higher[#higher+1] = node2.zones[i] end
  
  assert(#lower~=0 and #middle~=0 and #higher~=0, 'GrammarLib.SplitByTwoPivots - empty split')
  return lower, middle, higher

end

--- Split features in a way that all that can go to the new 
-- @param features List of features to distribute
-- @param gozones List of zones which features should be filtered out
-- @return Tuple with remain, go features
function GrammarLib.SplitFeaturesGreedy(features, gozones)
  
  local remain={}
  local go={}
  for i=1,#features do 
    local f = features[i]
    local gone = false
    
    for j=1,#gozones do
      local z = gozones[j]
      if f.zlevel==z.zlevel and f.ztype==z.ztype then
        gone = true
        break
      end
    end
    
    if gone then 
      go[#go+1] = f
    else
      remain[#remain+1] = f
    end
  end
    
  return remain, go

end


--- Shuffles indexes for given list
-- list List to 'shuffle'
-- @return List of shuffled indexes (1 to #list)
function GrammarLib.ShuffleIndexes(list)
  local rand = math.random
  local indexes = {}
  for i=1,#list do indexes[i]=i end
  for i = #indexes, 2, -1 do
      local j = rand(i)
      indexes[i], indexes[j] = indexes[j], indexes[i]
  end
  return indexes
end

--[[
function GrammarLib.showzones(node)
  local str_copy = {}
  for i,zone in ipairs(node.zones) do
    str_copy[i] = GrammarLib.showzone(zone)
  end
  print (table.concat(str_copy, ', '))
end


function GrammarLib.showzone(zone)
  return '<'..zone.zlevel..','..zone.ztype..'>'
end
--]]





return GrammarLib