
--- Handles pretty-printing
-- @class table
-- @name PrettyPrinter
local ConfigReader = {}

--- Reads existing config and returns loaded values
-- @param filepath The path to existing config file
function ConfigReader.read(filepath)
  local f,e = loadfile(filepath)
  if f==nil then
    error ("LUA ERROR (ConfigReader):"..e)
    return nil
  end
  -- clever trick below ;-)
  local data = {}
  setfenv(f, data) -- https://www.lua.org/manual/5.1/manual.html#pdf-setfenv 
  local ok,e = pcall(f)
  if not ok then
    error ("LUA ERROR (ConfigReader):"..e)
    return nil
  end 
  return data
end

return ConfigReader