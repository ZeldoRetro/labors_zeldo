local item = ...
local game = item:get_game()

function item:on_created()

  -- Define the properties.
  item:set_shadow("small")
  self:set_savegame_variable("possession_cane_of_byrna")
  self:set_assignable(true)
end

function item:on_using()

  local magic_needed = game:get_max_life() - game:get_life()  -- Number of magic points required

  game:get_hero():set_animation("cane_byrna", function()
    		if self:get_game():get_magic() >= magic_needed then
       			sol.audio.play_sound("cane")
    
            game:set_life(game:get_max_life())        
            game:remove_magic(magic_needed)
    			  cane_active = true
    		else
      			sol.audio.play_sound("wrong")
            game:start_dialog("_need_magic")
    		end
    game:get_hero():unfreeze()
  	item:set_finished()
  end)
end