local map = ...
local game = map:get_game()

map:register_event("on_started", function(map, destination)
  -- Niveau de l'eau et escaliers
  if game:get_value("dungeon_10015_water_level") == 1 then 
    map:set_entities_enabled("water_low",false)
  end
end)

-- TOUCHER LES DALLES BRUNES REFERME LA PORTE
for sensor in map:get_entities("sensor_close_auto_door_3_") do
  function sensor:on_activated()
    if auto_door_3:is_open() then
      sol.audio.play_sound("wrong")
      map:close_doors("auto_door_3")
      map:set_entities_enabled("sensor_close_auto_door_3_", true)
      auto_switch_auto_door_3:set_activated(false)
    end
  end
end

-- ÉNIGME DE SWITCHES POUR CLÉ DU BOSS
function auto_switch_auto_chest_boss_key_wrong_switch:on_activated()
  if boss_key_puzzle_switch_NO:is_activated() and boss_key_puzzle_switch_N:is_activated() and boss_key_puzzle_switch_NE:is_activated() and boss_key_puzzle_switch_E:is_activated() and boss_key_puzzle_switch_SE:is_activated() and boss_key_puzzle_switch_S:is_activated() and boss_key_puzzle_switch_SO:is_activated() and boss_key_puzzle_switch_O:is_activated() then
    auto_switch_auto_chest_boss_key:set_activated(true)
    auto_switch_auto_chest_boss_key:on_activated()
  else
    sol.timer.start(map, 500, function()
      sol.audio.play_sound("wrong")
      auto_switch_auto_chest_boss_key_wrong_switch:set_activated(false)
    end)
  end
end

function boss_key_puzzle_switch_NO:on_activated()
  if boss_key_puzzle_switch_N:is_activated() then boss_key_puzzle_switch_N:set_activated(false) else boss_key_puzzle_switch_N:set_activated(true) end
  if boss_key_puzzle_switch_O:is_activated() then boss_key_puzzle_switch_O:set_activated(false) else boss_key_puzzle_switch_O:set_activated(true) end
end

function boss_key_puzzle_switch_N:on_activated()
  if boss_key_puzzle_switch_NO:is_activated() then boss_key_puzzle_switch_NO:set_activated(false) else boss_key_puzzle_switch_NO:set_activated(true) end
  if boss_key_puzzle_switch_NE:is_activated() then boss_key_puzzle_switch_NE:set_activated(false) else boss_key_puzzle_switch_NE:set_activated(true) end
end

function boss_key_puzzle_switch_NE:on_activated()
  if boss_key_puzzle_switch_N:is_activated() then boss_key_puzzle_switch_N:set_activated(false) else boss_key_puzzle_switch_N:set_activated(true) end
  if boss_key_puzzle_switch_E:is_activated() then boss_key_puzzle_switch_E:set_activated(false) else boss_key_puzzle_switch_E:set_activated(true) end
end

function boss_key_puzzle_switch_E:on_activated()
  if boss_key_puzzle_switch_NE:is_activated() then boss_key_puzzle_switch_NE:set_activated(false) else boss_key_puzzle_switch_NE:set_activated(true) end
  if boss_key_puzzle_switch_SE:is_activated() then boss_key_puzzle_switch_SE:set_activated(false) else boss_key_puzzle_switch_SE:set_activated(true) end
end

function boss_key_puzzle_switch_SE:on_activated()
  if boss_key_puzzle_switch_E:is_activated() then boss_key_puzzle_switch_E:set_activated(false) else boss_key_puzzle_switch_E:set_activated(true) end
  if boss_key_puzzle_switch_S:is_activated() then boss_key_puzzle_switch_S:set_activated(false) else boss_key_puzzle_switch_S:set_activated(true) end
end

function boss_key_puzzle_switch_S:on_activated()
  if boss_key_puzzle_switch_SE:is_activated() then boss_key_puzzle_switch_SE:set_activated(false) else boss_key_puzzle_switch_SE:set_activated(true) end
  if boss_key_puzzle_switch_SO:is_activated() then boss_key_puzzle_switch_SO:set_activated(false) else boss_key_puzzle_switch_SO:set_activated(true) end
end

function boss_key_puzzle_switch_SO:on_activated()
  if boss_key_puzzle_switch_S:is_activated() then boss_key_puzzle_switch_S:set_activated(false) else boss_key_puzzle_switch_S:set_activated(true) end
  if boss_key_puzzle_switch_O:is_activated() then boss_key_puzzle_switch_O:set_activated(false) else boss_key_puzzle_switch_O:set_activated(true) end
end

function boss_key_puzzle_switch_O:on_activated()
  if boss_key_puzzle_switch_NO:is_activated() then boss_key_puzzle_switch_NO:set_activated(false) else boss_key_puzzle_switch_NO:set_activated(true) end
  if boss_key_puzzle_switch_SO:is_activated() then boss_key_puzzle_switch_SO:set_activated(false) else boss_key_puzzle_switch_SO:set_activated(true) end
end