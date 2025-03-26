-- Initialize map features specific to this quest.

require("scripts/multi_events")

local map_meta = sol.main.get_metatable("map")
     
-- SYSTEME DE JOUR/NUIT

-- Crépuscule (+ aube avec effet soleil levant)
local twilight = sol.surface.create(320,240)
twilight:set_blend_mode("multiply")
twilight:fill_color({244, 116, 0})
local twilight_surface_yellow = sol.surface.create(320,240)
twilight_surface_yellow:set_blend_mode("add")
twilight_surface_yellow:fill_color({63, 42, 0})
local twilight_surface_red = sol.surface.create(320,240)
twilight_surface_red:set_blend_mode("multiply")
twilight_surface_red:fill_color({255, 173, 226})

-- Nuit
local night_surface = sol.surface.create(320,240)
night_surface:set_blend_mode("multiply")
night_surface:fill_color({0, 33, 164})

map_meta:register_event("on_draw",function(map,dst_surface)
  local game = map:get_game()
  local hero = map:get_hero()

  -- LUMIÈRE CRÉPUSCULE
  if game:get_map():is_outside() then
    if game:get_value("twilight") then
      twilight:draw(dst_surface) 
      --twilight_surface_red:draw(dst_surface) 
      twilight_surface_yellow:draw(dst_surface)
    end
  end
end)


local ceiling_drop_manager = require("scripts/ceiling_drop_manager")
for _, entity_type in pairs({"hero"}) do
  ceiling_drop_manager:create(entity_type)
end

-- DEFINES IF THE MAP IS IN OUTSIDE
map_meta:register_event("is_outside",function(map)

  local game = map:get_game()

  if game:get_map():get_world() == "outside_light"
  or game:get_map():get_world() == "outside_light_2"
  or map:get_world() == "outside_light_labors_tott"
  or map:get_world() == "outside_light_labors_1st_solarus_quest"
  or map:get_entity("EXCEPTION_outside") ~= nil
  then
    return true
  end

end)

-- DEFINES IF THE MAP IS IN INSIDE
map_meta:register_event("is_inside",function(map)

  local game = map:get_game()

  if game:are_small_keys_enabled()
  or map:get_world() == "inside_world"
  or map:get_world() == "inside_world_labors_tott"
  or map:get_world() == "inside_world_labors_1st_solarus_quest"
  or map:get_entity("EXCEPTION_inside") ~= nil
  then
    return true
  end

end)

-- DEFINES IF THE MAP IS OBSCURE (DARK ROOM OR NIGHT)
map_meta:register_event("is_obscure",function(map)

  local game = map:get_game()

  if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("shadow_degree") ~= nil
  or game:get_value("night")
  or game:get_value("dawn")
  then
    return true
  end

end)

-- FOR SEPARATOR AND ENEMIES SYSTEM : DISABLE ALL ENEMIES EXCEPT IN CURRENT ROOM
map_meta:register_event("disable_all_enemies_except_for_current_room",function(map)

  local game = map:get_game()

  -- Disable all enemies in the map
  for enemy in map:get_entities_by_type("enemy") do
    local is_boss = enemy:get_property("is_major") == "true"
    if not is_boss then
      enemy:set_enabled(false)
    end
  end

  -- Enable enemies in the same room
  local hero = map:get_hero()
  for entity in map:get_entities_in_region(hero) do
    if entity:get_type() == "enemy" then
      local is_boss = entity:get_property("is_major") == "true"
      if not is_boss then
        entity:set_enabled(true)
      end
    end
  end

end)

-- DÉBUT DE LA MAP
map_meta:register_event("on_started",function(map, destination)

  local door_manager = require("maps/lib/door_manager")
  door_manager:manage_map(map)
  local chest_manager = require("maps/lib/chest_manager")
  chest_manager:manage_map(map)
  local separator_manager = require("maps/lib/separator_manager")
  separator_manager:manage_map(map)

  local game = map:get_game()
  local hero = map:get_hero()

  local music_map
  if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("music_map") ~= nil then
    music_map = map:get_entity("init_map"):get_property("music_map")
  else music_map = map:get_music() end

  -- Effet de chute (Ceiling Drop Manager)
  local ground = game:get_value("tp_ground")
  if ground =="hole" then
    hero:set_invincible(true)
    hero:set_visible(false)
    for entity in map:get_entities_by_type("sensor") do
      if entity:is_enabled() then
        entity:set_enabled(false)
        entity.temporary_disactivated = true
      end
    end
    sol.timer.start(map, 1500, function()
      for entity in map:get_entities_by_type("sensor") do
        if entity.temporary_disactivated ~= nil then
          entity:set_enabled(true)
          entity.temporary_disactivated = nil
        end
      end
    end)   
  else
    hero:set_visible()
  end

  -- Initialisation texte lieu
  local text_key_id
  if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("location_key") ~= nil then text_key_id = map:get_entity("init_map"):get_property("location_key") end

  texte_lieu = sol.text_surface.create{
    text_key = text_key_id,
    font = "alttp",
    font_size = 24,
    horizontal_alignment = "left",
    vertical_alignment = "middle",
  }

  -- Map dans l'obscurité
  if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("shadow_degree") ~= nil then
    if tonumber(map:get_entity("init_map"):get_property("shadow_degree")) == 1 then
      game:set_value("dark_room_middle",true)
      sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)
    elseif tonumber(map:get_entity("init_map"):get_property("shadow_degree")) == 2 then
      game:set_value("dark_room",true)
      sol.timer.start(map,10,function() game:set_value("dark_room",false) end)
    end
  end

  -- Initialisation map intérieure
  if map:is_inside() then

    -- Donjon
    -- Boss vaincu et conteneur de coeur disponible
    if map:get_entities("door_boss") ~= nil and map:get_entity("heart_container_spot") ~= nil then
      if game:get_value("boss_"..game:get_dungeon_index()) then 
        map:set_doors_open("door_boss")
        local x, y, layer = map:get_entity("heart_container_spot"):get_position()
        map:create_pickable{
          treasure_name = "quest_items/heart_container",
          treasure_variant = 1,
          treasure_savegame_variable = "heart_container_"..game:get_dungeon_index(),
          x = x,
          y = y,
          layer = layer
        }
      end
    end

    -- Système jour/nuit: entités actives ou non
    if game:get_value("day") or game:get_value("twilight") then
      -- Jour/Crépuscule
      map:set_entities_enabled("night_entity",false)
    elseif game:get_value("night") or game:get_value("dawn") then
      -- Nuit/Aube
      map:set_entities_enabled("day_entity",false)
    end
  end

  --Assaut de Ganondorf
  --[[if game:get_value("ganondorf_dominated_hyrule") then
    sol.audio.play_music("rain")
    map:set_entities_enabled("enemy",true)
    map:set_entities_enabled("soldier",false)
    map:set_entities_enabled("night_entity_soldier",false)
    dark = true
    if game:get_value("day") or game:get_value("twilight") then
      map:set_entities_enabled("night_entity",false)
      map:set_entities_enabled("fairy_power_fragment",false)
    elseif game:get_value("night") or game:get_value("dawn") then
      map:set_entities_enabled("day_entity",false)
    end
--]]

  -- Initialisation map extérieure
  if map:is_outside() then

    -- Zone explorée
    if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("explored_area") ~= nil then game:set_value(map:get_entity("init_map"):get_property("explored_area"),true) end
    -- Temps qui passe
    if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("timelapse") ~= nil then
      if map:get_entity("init_map"):get_property("timelapse") == "true" then game:set_value("timelapse",true) else game:set_value("timelapse",false) end
    end
    -- Sortie d'une Auberge ?
    if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("inn_exit") ~= nil then
      if map:get_entity("init_map"):get_property("inn_exit") == "true" then game:set_value("get_inn_key",false) game:set_value("inn_door_opened",false) end
    end
    -- Enemis en fonction du moment du jeu
    if game:get_value("periode_1") then map:set_entities_enabled("enemy_p1",true) end

    -- Système jour/nuit: entités actives ou non, musique, etc.
    if game:get_value("day") or game:get_value("twilight") then
      -- Jour/Crépuscule
      if map:get_entity("EXCEPTION_outside") == nil then sol.audio.play_music(music_map) end
      map:set_entities_enabled("night_entity",false)
      map:set_entities_enabled("fairy_power_fragment",false)
    elseif game:get_value("night") or game:get_value("dawn") then
      -- Nuit/Aube
      if map:get_entity("EXCEPTION_outside") == nil then sol.audio.play_music(music_map.."_night") end
      map:set_entities_enabled("day_entity",false)
    end
  end

end)

-- APRÈS OUVERTURE DE LA MAP
map_meta:register_event("on_opening_transition_finished",function(map)
  local game = map:get_game()

  -- Affichage lieu
  location_text_background:fade_in(20)
  texte_lieu:fade_in(50)
  sol.timer.start(4000, function() location_text_background:fade_out(50) end)
  sol.timer.start(4000, function() texte_lieu:fade_out(20) end)

  -- Temps qui passe
  if map:is_outside() and game:get_value("timelapse") then
    sol.timer.start(30000, function() 
      daytime_increment = true 
      sol.audio.play_sound("time_cycle")
    end)
  end

  -- Détecteur: Bruit si fragment de Force a proximité
  if game:get_value("get_gems_detector") then
    for entity in game:get_map():get_entities("power_gem_") do
      sol.audio.play_sound("detector")
    end
    for entity in game:get_map():get_entities("hidden_power_gem_") do
      sol.audio.play_sound("detector")
    end
  end

  -- Effet de chute
  local hero = game:get_hero()
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_invincible()
    hero:set_visible(false)
    hero:fall_from_ceiling(240, nil, function()
        sol.audio.play_sound("hero_lands")
        game:set_value("tp_ground","traversable")
        hero:set_invincible(false)
    end)
  end

  -- Seuls les ennemis dans la zone actuelle sont actifs
  -- ATTENTION : DÉCOMMENTER LA CONDITION POUR DÉSACTIVER EN OVERWORLD
  if map:is_inside() then
    map:disable_all_enemies_except_for_current_room(map)
  end

end)

map_meta:register_event("move_camera",function(map, x, y, speed, callback, delay_before, delay_after)

  local camera = map:get_camera()
  local game = map:get_game()
  local hero = map:get_hero()

  delay_before = delay_before or 1000
  delay_after = delay_after or 1000

  local back_x, back_y = camera:get_position_to_track(hero)
  game:set_suspended(true)
  camera:start_manual()

  local movement = sol.movement.create("target")
  movement:set_target(camera:get_position_to_track(x, y))
  movement:set_ignore_obstacles(true)
  movement:set_speed(speed)
  movement:start(camera, function()
    local timer_1 = sol.timer.start(map, delay_before, function()
      if callback ~= nil then
        callback()
      end
      local timer_2 = sol.timer.start(map, delay_after, function()
        local movement = sol.movement.create("target")
        movement:set_target(back_x, back_y)
        movement:set_ignore_obstacles(true)
        movement:set_speed(speed)
        movement:start(camera, function()
          game:set_suspended(false)
          camera:start_tracking(hero)
          if map.on_camera_back ~= nil then
            map:on_camera_back()
          end
        end)
      end)
      timer_2:set_suspended_with_map(false)
    end)
    timer_1:set_suspended_with_map(false)
  end)
end)

map_meta:register_event("on_finished", function(map)
  local game = map:get_game()
  texte_lieu_on = false
  nb_torches_lit = 0
  temporary_torches = false

  hero_slowed = false
  map:get_hero():set_walking_speed(88)

  -- Système jour/nuit: Temps qui passe
  if daytime_increment then
    daytime_increment = false
    game:set_value("daytime",game:get_value("daytime") + 1)
    if game:get_value("daytime") > 6 then game:set_value("daytime", 1) end
    if game:get_value("daytime") == 3 then 
      game:set_value("day",false)
      game:set_value("twilight",true) 
      game:set_value("night",false)
      game:set_value("dawn",false)
    elseif game:get_value("daytime") == 4 or game:get_value("daytime") == 5 then
      game:set_value("day",false)
      game:set_value("twilight",false) 
      game:set_value("night",true)
      game:set_value("dawn",false)
    elseif game:get_value("daytime") == 6 then
      game:set_value("day",false)
      game:set_value("twilight",false) 
      game:set_value("night",false)
      game:set_value("dawn",true)
    else
      game:set_value("day",true)
      game:set_value("twilight",false) 
      game:set_value("night",false)
      game:set_value("dawn",false)
    end
  end
end)

return true