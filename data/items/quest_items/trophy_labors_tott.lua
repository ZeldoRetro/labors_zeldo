--Trophy: An exemple item to finish a dungeon.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_sound_when_brandished("treasure_key_item")
  self:set_savegame_variable("possession_trophy_labors_tott")
  self:set_amount_savegame_variable("trophy_labors_tott_amount")
  self:set_max_amount(12)
end

function item:on_obtained()
  local game = item:get_game()
  local hero = game:get_hero()
  item:add_amount(1)
    hero:freeze()
    game:set_pause_allowed(false)
    game:set_life(game:get_max_life())
    game:set_magic(game:get_max_magic())
    sol.audio.play_music("victory")
    sol.timer.start(8000,function() 
       hero:start_victory()
       sol.timer.start(1000,function()
    	  game:set_pause_allowed(true)
        hero:teleport("creations/labors/tott/hub","start_wave_1","fade")
       end)     
    end)
end