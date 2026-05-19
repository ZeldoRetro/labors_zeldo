local map = ...
local game = map:get_game()

local light_img = sol.surface.create(432,240)
light_img:fill_color({255, 255, 255})
local light = false

local phase_1 = false

local end_ok = false
local hero_dead = false
local saved_by_fairy = false

-- Effet de distorsion en arrière plan

local x_background, y_background = distorsion_effect:get_position()
local x_background_max, y_background_max = 0, 0
local distorsion_speed = 2.0

-- Distorsion effect
map:register_event("on_draw",function()
  y_background = y_background + distorsion_speed

  if y_background >= y_background_max then 
    y_background = -320
  end

  distorsion_effect:set_position(x_background, y_background)
end)

map:register_event("on_started",function(map)

  --game:set_hud_enabled(false)
  game:set_pause_allowed(false)

  sol.timer.start(map, 10, function() hero:freeze() hero:set_layer(0) end)

  camera = map:get_camera()
  camera:start_tracking(zeldo_npc)

  light = true
  light_img:fade_out(100,function()
    light = false
    game:start_dialog("LABORS.zeldo_wave_1.battle_start",function()
      local camera_movement = sol.movement.create("target")
      camera_movement:set_ignore_obstacles(true)
      camera_movement:set_target(camera:get_position_to_track(hero))
      camera_movement:set_speed(256)
      camera_movement:start(camera, function()
        camera:start_tracking(hero)
        zeldo_npc:set_enabled(false)
        zeldo_boss:set_enabled()
        map:set_entities_enabled("firewall_", true)
        game:set_max_life(20*4)
        game:set_life(game:get_max_life())
        phase_1 = true
        sol.audio.play_music("creations/labors/13th_struggle")
        hero:unfreeze()
      end)
    end)
  end)
end)

map:register_event("on_draw",function(map,dst_surface)
  if light then light_img:draw(dst_surface) end
end)

function map:on_update()
  if phase_1 then
    if game:get_life() < 4 then
      distorsion_speed = 0.3
      sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_1_voice/laugh")
      sol.audio.play_music("none")
      phase_1 = false
      zeldo_boss:restart_fight()
      map:remove_entities("zeldo_"..tostring(zeldo_boss))
      game:set_life(1)
      hero:freeze()
      hero:set_animation("dying")
      sol.audio.play_sound("hero_dying")
      sol.timer.start(map,4000,function()
        game:start_dialog("LABORS.zeldo_wave_1.stop_the_joke",function()
          game:set_life(game:get_max_life())
          hero:unfreeze()
          zeldo_boss:stop_the_joke()
          sol.audio.play_music("creations/labors/revenge_of_chaos")
          sol.timer.start(map, 5000, function()
            game:start_dialog("LABORS.zeldo_wave_1.give_sword",function()
              map:create_pickable{
                treasure_name = "equipment/sword_PLAYER",
                treasure_variant = 1,
                x = 376,
                y = 205,
                layer = 0
              }
            end)
          end)
        end)
      end)
    end
  else
    if game:get_life() < 1 and not saved_by_fairy then
      local bottle_with_fairy = nil
      if game.get_first_bottle_with ~= nil then
        bottle_with_fairy = game:get_first_bottle_with(6)
      end
      if bottle_with_fairy ~= nil then
        saved_by_fairy = true
        sol.timer.start(map, 10000, function() saved_by_fairy = false end)
      else
        if not hero_dead then
          hero_dead = true
          sol.timer.start(game, 3000, function()
            game:get_item("equipment/sword_PLAYER"):set_variant(0)
            sol.audio.play_sound(sol.language.get_language().."/zeldo_wave_1_voice/gonna_cry")
            local i = game:get_value("death_counter_zeldo_wave_1")
            if i == nil then i = 0 end
            game:set_value("death_counter_zeldo_wave_1",i + 1)
            print("Eh eh eh... ça fait "..game:get_value("death_counter_zeldo_wave_1").."-0 !")
          end)
        end
      end
    end
  end
  if map:get_entity("end_battle"):is_enabled() then
    if not end_ok then
      hero:freeze()
      end_ok = true
      for i = 1, 4 do
        i = i + 1
        local x, y = zeldo_boss:get_position()
        local entity = map:create_custom_entity({
          layer = 2,
          x = x,
          y = y,
          direction = 0,
          width = 8,
          height = 8,
          sprite = "enemies/boss/zeldo_mask_particle",
        })
        local m = sol.movement.create("straight")
        m:set_speed(math.random(144,256))
        m:set_angle(math.random(1,360))
        m:set_max_distance(0)
        m:start(entity)
      end
      game:set_value("zeldo_wave_1_defeated",true)
      sol.timer.start(map, 2500, function()
        hero:teleport("creations/labors/castle_oblivion_1ET","after_zeldo_battle","immediate")
      end)
    end
  end
end