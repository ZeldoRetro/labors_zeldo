--Trophy: An exemple item to finish a dungeon.

local item = ...
local target_dest

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_sound_when_brandished("treasure_key_item")
  self:set_savegame_variable("possession_trophy_labors_retranscriptions")
  self:set_amount_savegame_variable("trophy_labors_retranscriptions_amount")
  self:set_max_amount(8)
end

function item:on_obtained()
  local game = item:get_game()
  local map = game:get_map()
  local hero = game:get_hero()

  -- Calcul map destination
  if map:get_world() == "dungeon_10021"
  or map:get_world() == "dungeon_10022"
  or map:get_world() == "dungeon_10023" then target_dest = "start_wave_1"
  end

  item:add_amount(1)

  hero:freeze()
  game:set_pause_allowed(false)
  game:set_life(game:get_max_life())
  game:set_magic(game:get_max_magic())
  sol.audio.play_music("victory",false)
  sol.timer.start(8000,function() 
    hero:start_victory()
    sol.timer.start(1200,function()
      game:set_pause_allowed(true)
      hero:set_animation("stopped")
      hero:set_direction(3)
      game:start_dialog("_save",function(answer)
        if answer == 1 then game:save() sol.audio.play_sound("ok") end
        hero:teleport("creations/labors/retranscriptions/hub",target_dest,"fade")
      end)        
    end)
  end)
end