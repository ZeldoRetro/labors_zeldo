-- Initialize sensor behavior specific to this quest.

require("scripts/multi_events")

local sensor_meta = sol.main.get_metatable("sensor")

sensor_meta:register_event("on_created", function(sensor)
  local game = sensor:get_game()
  local hero = game:get_hero()

  -- Disable the sensor if the savegame value passed in property is true (an opened door for example)
  if sensor:get_property("disable_if_value") ~= nil then
    if game:get_value(sensor:get_property("disable_if_value")) then
      sensor:set_enabled(false)
    end
  end

  -- Enable the sensor if the savegame value passed in property is true
  if sensor:get_property("enable_if_value") ~= nil then
    if game:get_value(sensor:get_property("enable_if_value")) then
      sensor:set_enabled(true)
    end
  end

end)

-- sensor_meta represents the default behavior of all sensors.
sensor_meta:register_event("on_activated", function(sensor)

  local hero = sensor:get_map():get_hero()
  local game = sensor:get_game()
  local map = sensor:get_map()
  local name = sensor:get_name()

  if name == nil then
    return
  end

  -- Sensors prefixed by "save_solid_ground_sensor" are where the hero come back
  -- when falling into a hole or other bad ground.
  if name:match("^save_solid_ground_sensor") then
    hero:save_solid_ground()
    return
  end
  -- Sensors prefixed by "reset_solid_ground_sensor" clear any place for the hero
  -- to come back when falling into a hole or other bad ground.
  if name:match("^reset_solid_ground_sensor") then
    hero:reset_solid_ground()
    return
  end

  -- Sensors prefixed by "dungeon_room_N" save the exploration state of the
  -- room "N" of the current dungeon floor.
  local room = name:match("^dungeon_room_(%d+)")
  if room ~= nil then
    game:set_explored_dungeon_room(nil, nil, tonumber(room))
    sensor:remove()
    return
  end

  --Prise en compte des layers et escaliers
  if name:match("^layer_up_sensor") then
    local x, y, layer = hero:get_position()
    if layer < map:get_max_layer() then
      hero:set_position(x, y, layer + 1)
    end
    return
  elseif name:match("^layer_down_sensor") then
    local x, y, layer = hero:get_position()
    if layer > map:get_min_layer() then
      hero:set_position(x, y, layer - 1)
    end
    return
  end

  --Affichage lieu
  if name:match("^texte_lieu") then
    texte_lieu_on = true
    sol.timer.start(6000, function() texte_lieu_on = false end)
    map:set_entities_enabled("texte_lieu",false)
  end
  if name:match("^not_texte") then
    map:set_entities_enabled("texte_lieu",false)
  end

  --Sensors qui ferment les portes derrière nous (définitives (ex:passage sens unique) ou temporaire (ex:combat))
  local j = 0
  while j ~= 9 do
    j = j + 1
    if name:match("^sensor_falling_auto_door_"..j) then
      map:set_entities_enabled(name,false)
      map:close_doors("auto_door_"..j)
    end
    if name:match("^sensor_falling_door_"..j) then
      map:close_doors("falling_door_"..j)
    end
    --Le héros avance tout seul et la porte se referme derrière lui
    if name:match("^sensor_push_hero_auto_door_"..j) then
      map:get_entity(name):set_enabled(false)
      local x, y, layer = hero:get_position()
      hero:freeze()
      hero:set_animation("walking")
      hero:set_direction(map:get_entity(name):get_property("direction"))
      local movement = sol.movement.create("straight")
      movement:set_speed(88)
      local angle
      movement:set_angle(map:get_entity(name):get_property("angle"))
      if layer == 1 then movement:set_max_distance(56) else movement:set_max_distance(80) end
      movement:start(hero,function() hero:unfreeze() end)
    end
    if name:match("^sensor_push_hero_other_door_"..j) then
      map:get_entity(name):set_enabled(false)
      local x, y, layer = hero:get_position()
      hero:freeze()
      hero:set_animation("walking")
      hero:set_direction(map:get_entity(name):get_property("direction"))
      local movement = sol.movement.create("straight")
      movement:set_speed(88)
      local angle
      movement:set_angle(map:get_entity(name):get_property("angle"))
      if layer == 1 then movement:set_max_distance(56) else movement:set_max_distance(80) end
      movement:start(hero,function() hero:unfreeze() end)
    end
    if name:match("^sensor_push_hero_falling_door_"..j) then
      local prefix = j
      local x, y, layer = hero:get_position()
      map:set_doors_open("falling_door_"..prefix)
      hero:freeze()
      hero:set_animation("walking")
      hero:set_direction(map:get_entity(name):get_property("direction"))
      local movement = sol.movement.create("straight")
      movement:set_speed(88)
      local angle
      movement:set_angle(map:get_entity(name):get_property("angle"))
      if layer == 1 then movement:set_max_distance(56) else movement:set_max_distance(80) end
      movement:start(hero,function() hero:unfreeze() end)
    end

  end

  --Son de secret après certains passages
  if name:match("^sensor_secret") then
    sol.audio.play_sound("secret")
  end

  -- Avertissement avant de quitter Auberge sans utiliser la clé
  if name:match("^exit_sensor_inn") then
    if game:get_value("get_inn_key") and not map:get_entity("inn_room_door"):is_open() then
      sensor:set_enabled(false)
      game:start_dialog("inn.exit_warning")
    end
  end  

  -- Joue une musique particulière en touchant le sensor
  if name:match("^play_music_sensor") then
    sol.audio.play_music(sensor:get_property("music_id"))
  end  

  --Pas de sons dans certains lieux (ex:avant boss)
  if name:match("^no_sound_sensor") then
    sol.audio.play_music("none")
  end  

  --Son revient une fois sorti du passage sans son
  local music_map = map:get_music()
  if name:match("^sound_sensor") then
    sol.audio.play_music(music_map)
  end

  --Entrée dans pièces de batailles
  if name:match("^sensor_battle") then
    map:close_doors("door_battle")
    hero:freeze()
    sol.audio.stop_music()
    sol.timer.start(1000,function()
      hero:unfreeze()
      sol.audio.play_music("battle")
      map:set_entities_enabled(name,false)
      map:set_entities_enabled("wave_1",true)
    end)
  end

  --Entrée dans pièce de miniboss
  if name:match("^sensor_miniboss") then
      hero:freeze()
      map:close_doors("door_miniboss")
      sol.audio.play_music("none")
      sol.timer.start(1000,function()
        hero:unfreeze()
        map:set_entities_enabled("miniboss",true)
        for enemy in map:get_entities("miniboss") do enemy:set_hurt_style("boss") end
        sol.audio.play_music("miniboss")
        map:set_entities_enabled(name,false)
      end)
  end

  --Entrée dans pièce de Boss
  if name:match("^sensor_boss") then
      hero:freeze()
      map:close_doors("door_boss")
      sol.audio.play_music("none")
      sol.timer.start(1000,function()
        --map:get_entity("texte_boss_1"):set_enabled(true)
        hero:unfreeze()
        map:get_entity("boss"):set_enabled(true)
        map:get_entity("boss"):set_hurt_style("boss")
        sol.audio.play_music("boss")
        map:set_entities_enabled(name,false)
        --map:get_entity("texte_boss_1"):set_enabled(false)
      end)
  end
end)

return true