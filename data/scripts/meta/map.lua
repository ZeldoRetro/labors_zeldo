-- Initialize map features specific to this quest.

require("scripts/multi_events")

local map_meta = sol.main.get_metatable("map")
texte_lieu_on = false
texte_boss_on = false

local monicle_img = sol.surface.create("backgrounds/monicle.png")
monicle_img:set_opacity(92)

sol.main.load_settings()
texte_lieu = sol.text_surface.create{
  text = "default",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}
location_text_background = sol.surface.create("menus/location_text_background.png")
     
--SYSTEME DE JOUR/NUIT
--Crépuscule (+ aube avec effet soleil levant)
local twilight = sol.surface.create(320,240)
twilight:set_blend_mode("multiply")
twilight:fill_color({244, 116, 0})
local twilight_surface_yellow = sol.surface.create(320,240)
twilight_surface_yellow:set_blend_mode("add")
twilight_surface_yellow:fill_color({63, 42, 0})
local twilight_surface_red = sol.surface.create(320,240)
twilight_surface_red:set_blend_mode("multiply")
twilight_surface_red:fill_color({255, 173, 226})
--Nuit
local night_surface = sol.surface.create(320,240)
night_surface:set_blend_mode("multiply")
night_surface:fill_color({0, 33, 164})

local ceiling_drop_manager = require("scripts/ceiling_drop_manager")
for _, entity_type in pairs({"hero"}) do
  ceiling_drop_manager:create(entity_type)
end

map_meta:register_event("on_draw",function(map,dst_surface)
  local game = map:get_game()
  local hero = map:get_hero()

  --EFFET MONOCLE DE VERITE
  if game:get_value("monicle_active") then
    monicle_img:draw(dst_surface)
  end

  --LUMIÈRE CRÉPUSCULE
  if game:get_map():get_world() == "outside_light" or game:get_map():get_world() == "outside_light_2"
  or map:get_id() == "creations/forgotten_legend/dungeons/4/1ET_outside" then
    if game:get_value("twilight") then
      twilight:draw(dst_surface) 
      --twilight_surface_red:draw(dst_surface) 
      twilight_surface_yellow:draw(dst_surface)
    end
  end


  --AFFICHAGE LIEU
  if texte_lieu_on then 
    location_text_background:draw(dst_surface)
    texte_lieu:draw(dst_surface, 8, 56) 
  end
  --AFFICHAGE BOSS
  --if texte_boss_on then texte_boss:draw(dst_surface) end
end)

--[[
map_meta:register_event("on_started",function(map)

  local game = map:get_game()
  local hero = map:get_hero()

  --SYSTEME JOUR/NUIT
  if game:get_map():get_world() == "outside_light" or game:get_map():get_world() == "outside_light_2"
  or map:get_id() == "creations/forgotten_legend/dungeons/4/1ET_outside" then
    if map:get_game():get_value("night") then
      map:set_darkness_level({0,33,164})                    
    elseif map:get_game():get_value("dawn") then
      map:set_darkness_level({255,94,109})
    end
  end
end)
--]]

map_meta:register_event("on_opening_transition_finished",function(map)
  local game = map:get_game()

  --Affichage lieu
  location_text_background:fade_in(20)
  texte_lieu:fade_in(50)
  sol.timer.start(4000, function() location_text_background:fade_out(50) end)
  sol.timer.start(4000, function() texte_lieu:fade_out(20) end)

  --Temps qui passe
  if not game:get_value("intro") and game:get_map():get_world() == "outside_light" and game:get_value("timelapse") then
    sol.timer.start(5000, function() 
      daytime_increment = true 
      sol.audio.play_sound("time_cycle")
    end)
  end

  --Détecteur: Bruit si fragment de Force a proximité
  if game:get_value("get_gems_detector") then
    for entity in game:get_map():get_entities("power_gem_") do
      sol.audio.play_sound("detector")
    end
    for entity in game:get_map():get_entities("hidden_power_gem_") do
      sol.audio.play_sound("detector")
    end
  end

  --Effet de chute
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

  --Système jour/nuit: Temps qui passe
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