-- Based on https://github.com/Nymphium/lua-graphviz

local function pcall_wrap(f, ...)
	local ok, cont = pcall(f, ...)

	if not ok then
		error(cont, 2)
	end

	return cont
end


local DrawLib = {} 


--- Main function to call Drawer
-- @param generator LMLGenerator with graph
-- @param filename Name of the output file (without extension)
-- @param remove_source Non-nil value if heleper .dot files should be removed
function DrawLib.Draw(generator, filename, remove_source) 
  
  
  DrawLib.WriteSource(generator, filename..'.dot')
  
  DrawLib.Compile(filename..'.dot', filename..'.png')
  
  if remove_source then
    os.remove(filename..'.dot')
  end
end



function DrawLib.Compile(filename, generate_filename)
	format = "png"

	generate_filename = generate_filename or ("%s.%s"):format(filename, format)

	-- compile dot file
	local cmd_str = ("dot -T%s %s -o %s"):format(
		format --[[output format]],
		filename --[[input dot file]],
		generate_filename --[[output file]])

	local cmd = io.popen(cmd_str, "r")
	pcall_wrap(cmd.read, cmd, "*a")
	pcall_wrap(io.close, cmd)
end

function DrawLib.ComputeSource(generator) -- todo make via table.concat
  
  local src = 'digraph G {\n'..'   edge [arrowhead="none"];\n\n'
  
  for id, node in ipairs(generator.nodesmap) do
  
    src = src..'   n'..id..' [label="'..node:Label()..'",'
    
    if not node:IsFinished() then
      src = src..'shape=doubleoctagon'
    elseif node.zones[1].ztype=='B' then
      src = src..'shape=box'
    else
      src = src..'shape=circle'
    end
    src = src..'];\n'
  
    for _, target in ipairs(node.edges) do
      if target.id > id then -- do not write double edges
        src = src .. '      n'..id..' -> n'..target.id..';\n'
      end
    end
  
  end
  
  src = src..'}' 
  
  return src
end

function DrawLib.WriteSource(generator, filename)
  
  local file = pcall_wrap(io.open, filename, "w+")

  file:write(DrawLib.ComputeSource(generator))
  pcall_wrap(io.close, file)

end





return DrawLib
