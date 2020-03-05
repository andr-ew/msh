include 'msh/lib/crops'
musicutil = require "musicutil"

-- pulling in our engine
engine_lib = require "molly_the_poly/lib/molly_the_poly_engine"
engine.name = "MollyThePoly"

msh = {}

msh.scales = { -- 4 different scales, go on & change em! can be any length. be sure 2 capitalize & use the correct '♯' symbol
  { "D", "E", "G", "A", "B" },
  { "D", "E", "F♯", "A", "B"},
  { "D", "E", "D", "A", "C" },
  { "D", "E", "F♯", "G", "B"}
}

msh.vel = function()
  return 0.8 + math.random() * 0.2 -- random logic that genrates a new velocity for each key press
end

msh.controls = crop:new{ -- controls at the top of the grid. generated using the crops lib - gr8 place to add stuff !
  scale = value:new{ v = 1, p = { { 1, 4 }, 1 } } -- value is kinda like a radio button. 2 named arguments are required to generate:
                                                  -- v (initial value), and p, table defining position (x start & end points, y)
}

msh.make_keyboard = function(rows, offset) -- function for generating a keyboard, optional # of rows + row separation
  local keyboard = crop:new{} -- new crop (control container)
  
  for i = 1, rows do -- make a single line keyboard for each row
    keyboard[i] = momentaries:new{ -- momentaries essentially works like a keybaord, hence we're using it
      v = {}, -- initial value is a blank table
      p = { { 1, 16 }, 9 - i }, -- y position stars at the bottom and moves up, x goes from 1 - 16
      offset = offset * i, -- pitch offset
      event = function(self, v, l, added, removed) -- event is called whenever the control is pressed
        local key
  			local gate
  			local scale = msh.scales[msh.controls.scale.v] -- get current sclae based on scale control value
  			
  			if added ~= -1 then -- notes added & removed are sent back throught thier respective arguments. defautls to -1 if no activity
  				key = added
  				gate = true
  			elseif removed ~= -1 then
  				key = removed
  				gate = false
  			end
  			
  			if key ~= nil then
  			  local note = scale[((key - 1) % #scale) + 1] -- grab note name from current scale
  			  
  			  for j,v in ipairs(musicutil.NOTE_NAMES) do -- hacky way of grabbing midi note num from note name
            if v == note then
              note = j - 1
              break
            end
  			  end
  			  
  			  note = note + math.floor((key - 1) / #scale) * 12 + self.offset -- add row offset and wrap scale to next octave
  			  
  			  if gate then
  			    msh.noteon(note)
  			  else
  			    msh.noteoff(note)
  			  end
  			end
      end
    }
  end
  
  return keyboard -- return our keybaord
end


msh.noteon = function(note)  
  engine.noteOn(note, musicutil.note_num_to_freq(note), msh.vel()) -- for noteOn send note number, freq, + generate a velocity
end

msh.noteoff = function(note) engine.noteOff(note) end

msh.keyboard = msh.make_keyboard(7, 12) -- call keybaord function w/ 8 rows & octave separation. u can change this !
  
function msh.g_key(g, x, y, z)
  crops:key(g, x, y, z)  -- sends keypresses to all controls auto-magically
  g:refresh()
end

function msh.g_redraw(g)
  crops:draw(g) -- redraws all controls
  g:refresh()
end

function msh.init()
  
  -- params stuff
  engine_lib.add_params() 
  params:set("freq_mod_env", 0.0)
  params:read()
end

msh.cleanup = function()
  
  --save paramset before script close
  params:write()
end

-------------------------- globals - feel free to redefine in referenced script

g = grid.connect()

g.key = function(x, y, z)
  msh.g_key(g, x, y, z)
end

function init()
  msh.init()
  msh.g_redraw(g)
end

function cleanup()
  msh.cleanup()
end

return msh