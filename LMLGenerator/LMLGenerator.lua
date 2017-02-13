local ConfigReader = require 'Configs/ConfigReader'

local Node = require('LMLGenerator/Node')
local Grammar = require('LMLGenerator/Grammar')
local Generator = require('LMLGenerator/Generator')
local DrawLib = require('LMLGenerator/DrawLib')



--- Generates LML graph given initial node info
-- todo - split into multiple functions if more than one LML will be generated
-- @param seed Random seed
-- @param initializer Data for initial graph node
function GenerateLML(seed, initializer)
  
  ---[[ For DEBUG ONLY
  if seed < 0 then
    seed = os.time() 
  end
  --]]
  
  math.randomseed( seed ) -- seed set (!)
  
  local config = ConfigReader.read('Configs/LMLGenerator.cfg')

  local drawdir = 'LMLGenerator/debug_graphs/'..seed..'-'
  
  local step=0
  local generator = Generator:New(Node:ParseNew(initializer))
  
  while not generator:IsFinished() do
    step = step+1

    if config.draw_nonfinal then
      DrawLib.Draw(generator, drawdir..step, true)
    end
    
    if config.verbose then
      generator:Show() -- prints generator data on the screen
    end
    
    generator:Step(Grammar)
    
    
  end

  if config.draw_final then
    DrawLib.Draw(generator, drawdir..'end', true) 
  end
  
  -- todo return the value in the right form into c++
  -- todo after splitting into multiple functions?
end

-- todo trials (?)
-- todo Evaluator (?)


--[[
-------------------------------------------------------------------------------
local INITSTATE = 'c' -- data/ file sufix
local GRAMMAR   = '01'  -- data/ file sufix
local TRIALS    = 1
local DRAW_NONFINAL = false
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


math.randomseed( os.time() )

local initialNode = require('data/init_'..INITSTATE)
local grammar = require('data/grammar_'..GRAMMAR)







-- testzone


for trial=1,TRIALS do
  print ('      TRIAL   '..trial..'/'..TRIALS)
  
  local prefix = 'out_graphs/'..INITSTATE..'-'..trial..'-'
  local step=0
  --local generator = Generator:New(Node:New(initialNode))
  local generator = Generator:New(Node:ParseNew(initialNode))
  --break
  
  --assert(#generator.root.edges==0) -- ups

-- to uncomment soon -- todo
  while not generator:IsFinished() do
    step = step+1

    if DRAW_NONFINAL then DrawLib.Draw(generator, prefix..step, true) end
      
    generator:Show()
    generator:Step(grammar)
    
    
  end

  DrawLib.Draw(generator, prefix..'end', true)  
end

--]]

