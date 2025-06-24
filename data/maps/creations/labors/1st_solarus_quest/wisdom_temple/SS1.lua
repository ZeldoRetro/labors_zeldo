local map = ...
local game = map:get_game()

map:register_event("on_started", function(map, destination)
  -- Initialisation bassins (sauvegardés entre étages)
  if game:get_value("dungeon_10015_bath_1") then
    map:set_entities_enabled("bath_2_step_", false)
    map:set_entities_enabled("bath_1_step_", true)
    for switch in map:get_entities("bath_1_switch_") do switch:set_activated(true) end
    for switch in map:get_entities("bath_2_switch_") do switch:set_activated(false) end
  elseif game:get_value("dungeon_10015_bath_2") then
    map:set_entities_enabled("bath_1_step_", false)
    map:set_entities_enabled("bath_2_step_", true)
    for switch in map:get_entities("bath_2_switch_") do switch:set_activated(true) end
    for switch in map:get_entities("bath_1_switch_") do switch:set_activated(false) end
  end

  -- Niveau de l'eau et escaliers
  if game:get_value("dungeon_10015_water_level") == 1 then 
    map:set_entities_enabled("water_low",false)
  end

  -- Torches allumées si clé 4 prise
  if game:get_value("key_10015_4") then
    block_puzzle_2_switch_1_torch:set_enabled(true)
    block_puzzle_2_switch_2_torch:set_enabled(true)
    block_puzzle_2_switch_3_torch:set_enabled(true)
    block_puzzle_2_switch_4_torch:set_enabled(true)
  end
end)

-- SWITCHES ET SYSTÈME DE BASSINS

for switch in map:get_entities("bath_2_switch_") do
  function switch:on_activated()
    hero:freeze()
    for switch in map:get_entities("bath_2_switch_") do switch:set_activated(true) end
    sol.audio.play_sound("water_drain")
    sol.timer.start(map, 1000, function()
      map:set_entities_enabled("bath_1_step_3_", false)
      map:set_entities_enabled("bath_2_step_1_", true)
      sol.timer.start(map, 1000, function()
        map:set_entities_enabled("bath_1_step_2_", false)
        map:set_entities_enabled("bath_2_step_2_", true)
        sol.timer.start(map, 1000, function()
          map:set_entities_enabled("bath_1_step_1_", false)
          map:set_entities_enabled("bath_2_step_3_", true)
          for switch in map:get_entities("bath_1_switch_") do switch:set_activated(false) end
          hero:unfreeze()
          sol.audio.play_sound("secret")
          game:set_value("dungeon_10015_bath_2",true)
          game:set_value("dungeon_10015_bath_1",false)
        end)
      end)
    end)
  end
end

for switch in map:get_entities("bath_1_switch_") do
  function switch:on_activated()
    hero:freeze()
    for switch in map:get_entities("bath_1_switch_") do switch:set_activated(true) end
    sol.audio.play_sound("water_drain")
    sol.timer.start(map, 1000, function()
      map:set_entities_enabled("bath_2_step_3_", false)
      map:set_entities_enabled("bath_1_step_1_", true)
      sol.timer.start(map, 1000, function()
        map:set_entities_enabled("bath_2_step_2_", false)
        map:set_entities_enabled("bath_1_step_2_", true)
        sol.timer.start(map, 1000, function()
          map:set_entities_enabled("bath_2_step_1_", false)
          map:set_entities_enabled("bath_1_step_3_", true)
          for switch in map:get_entities("bath_2_switch_") do switch:set_activated(false) end
          hero:unfreeze()
          sol.audio.play_sound("secret")
          game:set_value("dungeon_10015_bath_1",true)
          game:set_value("dungeon_10015_bath_2",false)
        end)
      end)
    end)
  end
end

-- ÉNIGME DE BLOCS 2: TORCHES QUI S'ALLUMENT
block_puzzle_2_switch_1:register_event("on_activated",function()
  sol.audio.play_sound("lamp")
  block_puzzle_2_switch_1_torch:set_enabled(true)
end)
block_puzzle_2_switch_1:register_event("on_inactivated",function()
  block_puzzle_2_switch_1_torch:set_enabled(false)
end)
block_puzzle_2_switch_2:register_event("on_activated",function()
  sol.audio.play_sound("lamp")
  block_puzzle_2_switch_2_torch:set_enabled(true)
end)
block_puzzle_2_switch_2:register_event("on_inactivated",function()
  block_puzzle_2_switch_2_torch:set_enabled(false)
end)
block_puzzle_2_switch_3:register_event("on_activated",function()
  sol.audio.play_sound("lamp")
  block_puzzle_2_switch_3_torch:set_enabled(true)
end)
block_puzzle_2_switch_3:register_event("on_inactivated",function()
  block_puzzle_2_switch_3_torch:set_enabled(false)
end)
block_puzzle_2_switch_4:register_event("on_activated",function()
  sol.audio.play_sound("lamp")
  block_puzzle_2_switch_4_torch:set_enabled(true)
end)
block_puzzle_2_switch_4:register_event("on_inactivated",function()
  block_puzzle_2_switch_4_torch:set_enabled(false)
end)