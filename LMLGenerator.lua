-------------------------------------------------------------------------------
local INITSTATE = 'c' -- data/ file sufix
local GRAMMAR   = '01'  -- data/ file sufix
local TRIALS    = 10
local DRAW_NONFINAL = false
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local Node = require('LMLLib/Node')
local GrammarLib = require('LMLLib/GrammarLib')
local Generator = require('LMLLib/Generator')
local DrawLib = require('LMLLib/DrawLib')

math.randomseed( os.time() )

local initialNode = require('data/init_'..INITSTATE)
local grammar = require('data/grammar_'..GRAMMAR)




for trial=1,TRIALS do
  print ('      TRIAL   '..trial..'/'..TRIALS)
  
  local prefix = 'out_graphs/'..INITSTATE..'-'..trial..'-'
  local step=0
  --local generator = Generator:New(Node:New(initialNode))
  local generator = Generator:New(Node:ParseNew(initialNode))
  --break
  
  --assert(#generator.root.edges==0) -- ups

  while not generator:IsFinished() do
    step = step+1
    
    if DRAW_NONFINAL then DrawLib.Draw(generator, prefix..step, true) end
      
    generator:Show()
    generator:Step(grammar)
    
    
  end

  DrawLib.Draw(generator, prefix..'end', true)  
end
