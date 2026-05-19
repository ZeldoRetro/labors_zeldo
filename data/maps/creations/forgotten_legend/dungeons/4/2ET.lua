local map = ...
local game = map:get_game()


--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)

  --Boss
  if game:get_value("boss_4") then 
    sensor_boss:set_enabled(false)
    khorneth_pnj:set_enabled(false)
    bokoblin_king_pnj:set_enabled(false)
    map:set_doors_open("door_boss")
    local x, y = heart_container_spot:get_position()
    map:create_pickable{
      treasure_name = "quest_items/heart_container",
      treasure_variant = 1,
      treasure_savegame_variable = "heart_container_4",
      x = x,
      y = y,
      layer = 1
    }
  else
    map:set_doors_open("door_boss_1")
    boss:set_enabled(false)
    khorneth_pnj:get_sprite():set_animation("immobilized")
    bokoblin_king_pnj:get_sprite():set_animation("immobilized") end

end)

function sensor_boss:on_activated()
  self:set_enabled(false)
  hero:freeze()
  map:close_doors("door_boss")
  sol.audio.play_music("none")
  bokoblin_king_pnj:get_sprite():set_direction(3)
  local m = sol.movement.create("straight")
  m:set_speed(128)
  m:set_angle(math.pi / 2)
  m:set_max_distance(80)
  m:set_ignore_obstacles(true)
  m:start(map:get_camera(),function()
    sol.timer.start(1000,function()
      game:set_dialog_position("bottom")
        game:set_dialog_position("auto")
        local x, y, layer = bokoblin_king_pnj:get_position()
        sol.audio.play_sound("cape_off")
        transformation_effect:set_enabled(true)
        transformation_effect:get_sprite():set_frame(0)
        transformation_effect:set_position(x, y - 4, layer + 1)
        sol.timer.start(map,300,function()
          bokoblin_king_pnj:set_enabled(false)
        end)
        khorneth_pnj:get_sprite():set_animation("awakening")
        sol.audio.play_sound("enemy_awake")
        local m = sol.movement.create("straight")
        m:set_speed(64)
        m:set_angle(math.pi / 2 * 3)
        m:set_max_distance(80)
        m:set_ignore_obstacles(true)
        m:start(map:get_camera(),function()
          sol.timer.start(map,500,function()
            map:get_camera():start_tracking(hero)
            hero:unfreeze()
            khorneth_pnj:set_enabled(false)
            map:get_entity("boss"):set_enabled(true)
            map:get_entity("boss"):set_hurt_style("boss")
            sol.audio.play_music("boss")
            map:set_entities_enabled("phase_1_wall_",true)
          end)
        end)
    end)
  end) 
end