--- Node Describes Logic Map Layout node
-- @class table
-- @name Node
--
-- @field id Identifier of the node (should be unique)
-- @field features List of features in format {zlevel,ztype,ftype,fvalue}
-- @field zones List of zones in format {zlevel,ztype}
-- @field edges List of neighboring nodes
local Node = {} 

--- Create new Node
-- @param content: Preinitialized table with node info (no-copy, plain take)
function Node:New(content)
  local obj = {id=1, zones={}, features={}, edges={}}
  setmetatable(obj, { __index = self })
  
  if content then
    if content.id then obj.id = content.id end
    if content.zones then obj.zones = content.zones end
    if content.features then obj.features = content.features end
    if content.edges then obj.edges = content.edges end
  end
  
  return obj
end


--- Node is finished when it has exactly one zone available
-- @return True only if one zone in node zones
function Node:IsFinished()
  return #self.zones == 1
end

--- Sort zones according to levels and if levels are equal then L < B
function Node:SortZones()
  table.sort (self.zones, function(a,b) return a.zlevel < b.zlevel or (a.zlevel==b.zlevel and a.ztype=='L' and b.ztype=='B') end)
end

--- Two-sided edge removal between nodes
-- @param node Node we want to remove edge to (and vice-versa)
function Node:RemoveEdge(node)
  
  local remove = nil
  for i, edge in ipairs(self.edges) do
    if edge.id==node.id then 
      remove = i 
      break
    end
  end
  if remove then table.remove(self.edges, remove) end
  
  remove = nil
  for i, edge in ipairs(node.edges) do
    if edge.id==self.id then 
      remove = i 
      break
    end
  end
  if remove then table.remove(node.edges, remove) end
end

--- Prepare label for graphviz node
-- @return String with node's zones and features
function Node:Label()
  if self:IsFinished() then
    
    local flabels = {}
    for i,f in ipairs(self.features) do
      flabels[i] = f.ftype
    end
  
    return self.zones[1].ztype..self.zones[1].zlevel..'\\n'..table.concat(flabels, ',')  
  end
  
  local zlabel = function(z) return z.ztype..z.zlevel end
  local flabel = function(f) return f.ftype..'-'..f.ztype..f.zlevel end
  
  local zlabels = {}
  for i,z in ipairs(self.zones) do
    zlabels[i] = zlabel(z)
  end
  
  local flabels = {}
  for i,f in ipairs(self.features) do
    flabels[i] = flabel(f)
  end
  
  return table.concat(zlabels, ',')..'\\n'..table.concat(flabels, ',')  
end


--- Creates new node given simplified initial data
-- @param initdata Node table with zones and features given as text
-- @return New, properly filled node
function Node:ParseNew(initdata)
  local zones = {}
  for ztype, zlevel in string.gmatch(initdata.zones, '(%a)(%d+)') do -- '([^,]+)'
    --print(ztype..'_'..zlevel)
    zones[#zones+1] = {zlevel=tonumber(zlevel),ztype=ztype}
  end
  
  local features = {}
  for ftype, ztype, zlevel in string.gmatch(initdata.features, '(%w+)%-(%a)(%d+)') do
    features[#features+1] = {ftype=ftype,zlevel=tonumber(zlevel),ztype=ztype}
  end
  
  -- todo features
  
  return Node:New({zones=zones,features=features})
end

return Node