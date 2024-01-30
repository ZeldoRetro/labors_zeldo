--Sword: increases the attack.

local item = ...

function item:on_created()

  self:set_savegame_variable("possession_sword")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end


function item:on_obtaining(variant)

  -- Obtaining the sword increases the force.
  local game = item:get_game()
  local map = game:get_map()
  local force = game:get_value("force")
  force = force + 1
  game:set_value("force", force)
end

function item:on_obtained(variant)
  local game = item:get_game()
  local hero = game:get_hero()
  if variant == 1 then
    if game:get_map():get_id() == "creations/ayttp/dungeons/winter_1/RDC" then
      hero:freeze()
      game:set_pause_allowed(false)
      game:set_life(game:get_max_life())
      game:set_magic(game:get_max_magic())
      game:set_dungeon_finished()
      sol.audio.play_music("victory")
      sol.timer.start(8000,function() 
         hero:start_victory()
         sol.timer.start(1000,function()
      	   game:set_pause_allowed(true)
           hero:teleport("creations/ayttp/outside/light/D5","hero_cave","fade")
         end)     
      end)
    end
  elseif variant == 2 then
    hero:start_victory()
    sol.timer.start(1500,function()
      game:set_pause_allowed(true)
      sol.audio.play_sound("door_open")
      game:get_map():set_entities_enabled("arena_wall_2",false)
    end)
  end
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
end