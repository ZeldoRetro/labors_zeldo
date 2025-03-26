-- Initialize switches behavior specific to this quest.

require("scripts/multi_events")

local switch_meta=sol.main.get_metatable("switch")

local puzzle_blocks = 0
local switch_reveals_path_counter = 0

local timer_door = {}

switch_meta:register_event("on_created", function(switch)

  local name = switch:get_name()
  local game = switch:get_game()
  local hero = game:get_hero()
  local map = game:get_map()

  -- Disable the switch if the savegame value passed in property is true
  if switch:get_property("disable_if_value") ~= nil then
    if game:get_value(switch:get_property("disable_if_value")) then
      switch:set_enabled(false)
    end
  end

  -- Enable the switch if the savegame value passed in property is true
  if switch:get_property("enable_if_value") ~= nil then
    if game:get_value(switch:get_property("enable_if_value")) then
      switch:set_enabled(true)
    end
  end

  -- Active the switch if the savegame value passed in property is true
  if switch:get_property("active_if_value") ~= nil then
    if game:get_value(switch:get_property("active_if_value")) then
      if switch:get_property("value_number") ~= nil then
        if game:get_value(switch:get_property("active_if_value")) == tonumber(switch:get_property("value_number")) then switch:set_activated(true) end
      else switch:set_activated(true) end
    end
  end

  -- Set the switch activated if it has this property
  if switch:get_property("already_activated") ~= nil then
    switch:set_activated(true)
  end

  -- Effet de lumière pour switch actif
  if switch:get_property("save_value") ~= nil then
    if game:get_value(switch:get_property("save_value")) then
      if map:get_entity(name.."_torch") ~= nil then
        map:get_entity(name.."_torch"):set_lit(true)
      end
    end
  end

  if name == nil then
    return
  end

  -- Switch qui révèle les chemins invisibles (via torches, ou pas)
  if name:match("^switch_reveals_path") then
    switch_reveals_path_counter = 0
  end

end)

switch_meta:register_event("on_activated", function(switch)

  local name = switch:get_name()
  local game = switch:get_game()
  local map = game:get_map()
  local hero = game:get_hero()

  if name == nil then
    return
  end

  -- Effet de lumière
  if map:get_entity(name.."_torch") ~= nil then
    map:get_entity(name.."_torch"):set_lit(true)
    map:get_entity(name.."_torch"):on_lit(true)
  end

  -- Fait disparaitre des entités de map autres que les portes, et sauvegarde leur état
  if switch:get_property("save_value") ~= nil then
    sol.audio.play_sound("secret")
    game:set_value(switch:get_property("save_value"), true)
    if switch:get_property("enable_entities") ~= nil then map:set_entities_enabled(switch:get_property("enable_entities"), true) end
    if switch:get_property("disable_entities") ~= nil then map:set_entities_enabled(switch:get_property("disable_entities"), false) end
  end

  -- Switches permettant une gestion de niveau de l'eau dans des Zones/Donjons
  if name:match("^switch_water_add") then
    hero:freeze()
    sol.audio.play_sound("correct")
    sol.audio.play_sound("water_fill")
    sol.timer.start(1000,function()
      map:set_entities_enabled("water_low",false)
      map:set_entities_enabled("layer_up_sensor",true)
      map:set_entities_enabled("layer_down_sensor",true)
      map:set_entities_enabled("water_flux_constant",true)
        map:set_entities_enabled("water_middle_2",true)
        map:set_entities_enabled("water_flux_1",true)
        sol.timer.start(1000,function()
          map:set_entities_enabled("water_middle_2",false)
          map:set_entities_enabled("water_middle_1",true)
          map:set_entities_enabled("water_flux_1",false)
          map:set_entities_enabled("water_flux_2",true)
          sol.timer.start(1000,function()
            map:set_entities_enabled("water_middle_1",false)
            map:set_entities_enabled("water_flux_2",false)
            map:set_entities_enabled("water_high",true)
            sol.audio.play_sound("secret")
            for switch in map:get_entities("switch_water_add_") do switch:set_activated(true) end
            for switch in map:get_entities("switch_water_remove_") do switch:set_activated(false) end
            game:set_value("dungeon_"..game:get_dungeon_index().."_water_level",tonumber(switch:get_property("water_level_set")))
            hero:unfreeze()
          end)
        end)
    end)
  end

  if name:match("^switch_water_remove") then
    hero:freeze()
    sol.audio.play_sound("correct")
    sol.audio.play_sound("water_drain")
    sol.timer.start(1000,function()
      map:set_entities_enabled("water_high",false)
      map:set_entities_enabled("water_flux",false)
      map:set_entities_enabled("water_middle_1",true)
      sol.timer.start(1000,function()
        map:set_entities_enabled("water_middle_1",false)
        map:set_entities_enabled("water_middle_2",true)
        sol.timer.start(1000,function()
          map:set_entities_enabled("water_middle_2",false)
          map:set_entities_enabled("water_low",true)
          map:set_entities_enabled("layer_up_sensor",false)
          map:set_entities_enabled("layer_down_sensor",false)
          sol.audio.play_sound("secret")
          for switch in map:get_entities("switch_water_add_") do switch:set_activated(false) end
          for switch in map:get_entities("switch_water_remove_") do switch:set_activated(true) end
          game:set_value("dungeon_"..game:get_dungeon_index().."_water_level",tonumber(switch:get_property("water_level_set")))
          hero:unfreeze()
        end)
      end)
    end)
  end

  -- Switch qui révèle les chemins invisibles (via torches, ou pas)
  if name:match("^switch_reveals_path") then
    for entity in map:get_entities("torch_path") do
      entity:set_visible(true)
    end
    switch_reveals_path_counter = switch_reveals_path_counter + 1
    sol.timer.start(map, tonumber(switch:get_property("duration")), function() 
      sol.audio.play_sound("switch")
      switch_reveals_path_counter = switch_reveals_path_counter - 1
      if switch_reveals_path_counter == 0 then
        for entity in map:get_entities("torch_path") do
        	entity:set_visible(false)
        end
      end
      switch:set_activated(false)
      -- Effet de lumière (éteint)
      if map:get_entity(name.."_torch") ~= nil then
        map:get_entity(name.."_torch"):set_lit(false)
        map:get_entity(name.."_torch"):on_unlit(true)
      end
    end)
  end

  -- Switches Étoiles qui gèrent les apparitions de trous ou autres entités en alternance
  if name:match("^switch_hole_B_") then
    sol.audio.play_sound("secret")
    map:set_entities_enabled("hole_B_", true)
    map:set_entities_enabled("hole_A_", false)
    for switch in map:get_entities("switch_hole_A_") do switch:set_activated(false) end
    for switch in map:get_entities("switch_hole_B_") do switch:set_activated(true) end
  end

  if name:match("^switch_hole_A_") then
    sol.audio.play_sound("secret")
    map:set_entities_enabled("hole_A_", true)
    map:set_entities_enabled("hole_B_", false)
    for switch in map:get_entities("switch_hole_B_") do switch:set_activated(false) end
    for switch in map:get_entities("switch_hole_A_") do switch:set_activated(true) end
  end

  local j = 0
  while j ~= 9 do
    j = j + 1

    -- Faux switch: fais apparaitre des ennemis
    if name:match("^wrong_switch_"..j) then
      sol.audio.play_sound("wrong")
      map:set_entities_enabled("wrong_switch_"..j.."_enemy",true)
    end

    -- Switches ouvrant portes pendant une limite de temps
    if name:match("^switch_timer_"..j) then
      local nb_switch = j
      local door_x, door_y = map:get_entity("door_timer_"..nb_switch):get_position()
      sol.audio.play_sound("correct") 
      map:move_camera(door_x,door_y,256,function() 
        map:open_doors("door_timer_"..nb_switch)
        timer_door[nb_switch] = sol.timer.start(map,tonumber(switch:get_property("duration")),function()
          sol.audio.play_sound("wrong")
          map:close_doors("door_timer_"..nb_switch)
          switch:set_activated(false) 
        end)
        timer_door[nb_switch]:set_with_sound(true)
      end)
    end

    if name:match("^timer_clear_switch_"..j) then
      local nb_switch = j
      timer_door[nb_switch]:stop()
      timer_door[nb_switch] = nil
      sol.audio.play_sound("secret")
      game:set_value(switch:get_property("save_value"), true)
    end

    -- Switch reset puzzle: reset les blocs mal placés pour une énigme de blocs
    if name:match("^block_puzzle_"..j.."_fake_switch") then
      local nb_switch = j
      sol.timer.start(map, 500, function() 
        local i = 0
        while i < tonumber(map:get_entity("block_puzzle_"..nb_switch.."_fake_switch"):get_property("nb_blocks")) do
          i = i + 1
          map:get_entity("block_puzzle_"..nb_switch.."_block_"..i):reset()
        end
        sol.audio.play_sound("wrong") 
        map:get_entity("block_puzzle_"..nb_switch.."_fake_switch"):set_activated(false)
        -- Effet de lumière (éteint)
        if map:get_entity(name.."_torch") ~= nil then
          map:get_entity(name.."_torch"):set_lit(false)
          map:get_entity(name.."_torch"):on_unlit(true)
        end
      end)
    end

    -- Switches gérant les énigmes de blocs
    if name:match("^block_puzzle_"..j.."_switch") then
      puzzle_blocks = tonumber(switch:get_property("current_blocks")) + 1
      for switch in map:get_entities("block_puzzle_"..j.."_switch_") do
        switch:set_property("current_blocks",puzzle_blocks)
      end
      if puzzle_blocks == tonumber(switch:get_property("goal_blocks")) then
        map:get_entity(switch:get_property("end_switch")):set_enabled(true)
        map:get_entity("block_puzzle_"..j.."_fake_switch"):set_enabled(false)
        local temp = j
        sol.timer.start(map, 100, function()
          local i = 0
          while i < tonumber(switch:get_property("goal_blocks")) do
            i = i + 1
            map:get_entity("definitive_block_puzzle_"..temp.."_block_"..i):set_enabled(true)
            map:get_entity("block_puzzle_"..temp.."_block_"..i):set_enabled(false)
          end
        end)
      end
    end

  end

end)

switch_meta:register_event("on_inactivated", function(switch)

  local name = switch:get_name()
  local game = switch:get_game()
  local map = game:get_map()
  local hero = game:get_hero()

  if name == nil then
    return
  end

  local j = 0
  while j ~= 9 do
    j = j + 1

    -- Switches gérant les énigmes de blocs
    if name:match("^block_puzzle_"..j.."_switch") then
      puzzle_blocks = tonumber(switch:get_property("current_blocks")) - 1
      for switch in map:get_entities("block_puzzle_"..j.."_switch_") do
        switch:set_property("current_blocks",puzzle_blocks)
      end
    end

  end

end)