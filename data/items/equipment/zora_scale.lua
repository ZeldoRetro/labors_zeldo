--Zora scale: Allows you to dive in water.

local item = ...
local game = item:get_game()
local multi_events = require("scripts/multi_events")

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  item.is_hero_diving = false
  self:set_savegame_variable("possession_zora_scale")
end

function item:on_obtaining()
  --L'écaille d'or permet de plonger plus longtemps
  if item:get_variant() == 2 then diving_time = 5000 else diving_time = 2000 end
end

game:register_event("on_command_pressed", function(game, command)
  if command == "attack" and game:get_hero():get_state() == "swimming" and item.is_hero_diving == false and game:get_value("get_zora_scale")then
    item:start_diving()
  end
end)

-- Start diving hero
function item:start_diving()
  item.is_hero_diving = true
  local hero = game:get_hero()
  hero:register_event("on_state_changed", function(hero, state)
    if item.is_hero_diving and hero:get_state() == "free" then
      item:stop_diving()
    end
  end)
  sol.audio.play_sound("splash")
  hero:freeze()
  hero:set_animation("diving",function()
    hero:unfreeze()
    hero:set_tunic_sprite_id("hero/diving")
    hero:set_invincible(true)
    sol.timer.start(item,diving_time,function()
      item:stop_diving()
    end)
  end)
end

-- Stop diving hero
function item:stop_diving()
  if item.is_hero_diving then
    local hero = game:get_hero()
    sol.audio.play_sound("splash")
    hero:set_tunic_sprite_id("hero/tunic"..game:get_ability("tunic"))
    hero:set_invincible(false)
    item.is_hero_diving = false
  end
end