local GrammarLib = require('LMLLib/GrammarLib')

--- Can apply grammar rules to work-in-progress LML
-- @class table
-- @name Generator
--
-- @field maxid Maximal id in the nodes (should be equal with #nodesmap)
-- @field root root Node (id 1, default with player town)
-- @field nodesmap Map of nodes {id->Node}
-- @field edges List of neighboring nodes
local Generator = {} 


--- Create new Generator
-- @param root Node which will be generator's root
function Generator:New(root)
  local obj = {maxid=1,root=root,nodesmap={root}}
  setmetatable(obj, { __index = self })
  return obj
end


--- Generator is finished when all nodes are finished (have exactly one zene assigned)
-- @returns True iff there is nothing more to do
function Generator:IsFinished()
  for i,node in ipairs(self.nodesmap) do
    if not node:IsFinished() then return false end
  end
  return true
end

--- Applies random grammatical rule 
-- @param grammar Grammar which should be used to make the next step
function Generator:Step(grammar)
  for _, i in ipairs(GrammarLib.ShuffleIndexes(grammar)) do
    local production = grammar[i]
    --print(i)
    local preconds = self:CheckProduction(production)
    if preconds then
      --print ('Production: '..i)
      self:CallProduction(preconds, production)
      return -- return with success
    end
  end
  error('Generator step error: no applicable production.', 2)
end

--- Check if production is applicable, returns its preconds or nil
function Generator:CheckProduction(production)
  
  --local arity = production.arity
  -- todo for more than one -- maybe in future ?
  
  for i, node in ipairs(self.nodesmap) do
    if not node:IsFinished() then
      local preconds = production.IsApplicable(node)
      if preconds then -- production applicable
        return preconds
      end
    end
  end
  return nil
end




--- Calls given production when it matches the preconditions
function Generator:CallProduction(preconditions, production)
  
  local effects = production.ComputeEffect(preconditions, self.maxid+1)
  
  for _,n in ipairs(effects) do
    self.nodesmap[n.id] = n
    n:SortZones() -- sort zones
    if n.id > self.maxid then self.maxid = n.id end
  end
  
end


--- Debug-purpose print of Generator status
function Generator:Show()
  local str = 'Generator <'..self.maxid..', '..self.root.id..' -> '

  local flabel = function(f) return f.ftype..'-'..f.ztype..f.zlevel end
  
  
  local nlabels = {}
  for i,n in ipairs(self.nodesmap) do
    if not n.id then error('Generator error ('..str..') '..i'-th node without id', 2) end
    if i ~= n.id then error('Generator error ('..str..') '..i'-th node with id '..n.id, 2) end
    nlabels[i] = n.id
  end

  str = str..table.concat(nlabels,',')..'>'

  print (str)
end


return Generator