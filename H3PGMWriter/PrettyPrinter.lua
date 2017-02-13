-- Inspired by: https://github.com/hipe/lua-table-persistence/blob/master/persistence.lua

--- Handles pretty-printing
-- @class table
-- @name PrettyPrinter
PrettyPrinter = {}

local indent = '  ' -- level 1 indentation string

--- Function for prett-printing simple Lua objects combined via tables
-- @param item Lua object to write down
-- @param level Level of indentation (default 0 for the root)
-- @iskey True (non-nil) if we try to write table key
-- @return String containing prett-printed item
function PrettyPrinter.prettyprinter(item, level, iskey)
  if not level then level = 0 end
  if level==0 then iskey = true end

  if type(item) == 'nil' then
    return 'nil'
  elseif type(item) == 'number' then
    return tostring(item)
  elseif type(item) == 'string' then
    if not iskey then return string.format("%q", item)
    else return item end
  elseif type(item) == 'boolean' then
    if item then return 'true'
    else return 'false' end
  elseif type(item) == 'table' then
    -- todo:
    -- table should be one-level if keys are only ints (then no keys specified)
    -- one-level if its description is 'short' (?)
    -- multi-level if contains table inside?
    
    
    
    local tab = {}
    if level > 0 then tab[1] = '\n'..indent:rep(level)..'{\n' end -- alternatively: level - 1
    
      for k, v in pairs(item) do
        local keystring = type(k) == 'string'
        if level > 0 then tab[#tab+1] = indent:rep(level+1).. (keystring and '' or '[') end -- alternatively: level - 1
        tab[#tab+1] = PrettyPrinter.prettyprinter(k, level, true)..(keystring and ' = ' or '] = ')
        tab[#tab+1] = PrettyPrinter.prettyprinter(v, level+1)
        tab[#tab+1] = level > 0 and ',\n' or '\n\n'
      end

    if level > 0 then tab[#tab+1] = indent:rep(level)..'}' end -- alternatively: level - 1
    --tab[#tab+1] = '\n'
    return table.concat(tab)
  else
    error ('Usupported type: '..type(item), 2)
  end
  
end


return PrettyPrinter
