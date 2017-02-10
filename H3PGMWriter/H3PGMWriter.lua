local PrettyPrinter = require 'H3PGMWriter/PrettyPrinter'


data = {}


--- Reads existing mapsave and puts loaded values into data
-- @param filepath The path to existing mapsave file
function read(filepath)
  local f,e = loadfile(filepath)
  if f==nil then
    error ("LUA ERROR: H3PMGWriter.read:"..e)
    return
  end
  -- clever trick below ;-)
  setfenv(f, data) -- https://www.lua.org/manual/5.1/manual.html#pdf-setfenv 
  local ok,e = pcall(f)
  if not ok then
    error ("LUA ERROR: H3PMGWriter.read:"..e)
    return
  end
  print ('< InLua, loaded: '..filepath)
end

--- Executes dictionary set on the data table
-- @param key Name of key in mapsave file
-- @param value The value tu put under the given key
function update(key, value)
  data[key] = value
  if key=='LML_initializer' then
    print ('< InLua: '..key..' -> zones.'..tostring(value.zones))
    print ('< InLua: '..key..' -> features.'..tostring(value.features))
  else
    print ('< InLua: '..key..' -> '..value)
  end
  
end

--- Saves mapsave to the file (owerwriting all) in pretty-printed form
-- @param The path to new mapdump file
function write(filepath)
  local pp = PrettyPrinter.prettyprinter(data)
  --print (PrettyPrinter.prettyprinter(data))
  local file = io.open(filepath, "w")
  file:write(pp)
  file:close()
  print ('< InLua, saved: '..filepath..' (length: '..pp:len()..')') -- todo len
end 

