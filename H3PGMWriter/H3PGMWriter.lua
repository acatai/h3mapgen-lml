local ConfigReader = require 'Configs/ConfigReader'
local PrettyPrinter = require 'H3PGMWriter/PrettyPrinter'


local data = {} -- stores all mapsave data 


--- Reads existing mapsave and puts loaded values into data
-- @param filepath The path to existing mapsave file
function load(filepath)
  data = ConfigReader.read(filepath)
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
function save(filepath)
  local pp = PrettyPrinter.prettyprinter(data)
  --print (PrettyPrinter.prettyprinter(data))
  local file = io.open(filepath, "w")
  file:write(pp)
  file:close()
  print ('< InLua, saved: '..filepath..' (length: '..pp:len()..')') -- todo len
end 

