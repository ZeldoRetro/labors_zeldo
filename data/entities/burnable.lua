-- Lua script of custom entity burnable.

local burnable = ...
local game = burnable:get_game()
local map = burnable:get_map()
local sprite

-- Tell the hookshot that it can hook to us.
function burnable:is_hookable()
  return true
end

function burnable:on_created()

  burnable:set_size(16, 16)
  burnable:set_origin(8, 13)
  burnable:set_traversable_by("hero", false)
  burnable:set_traversable_by("enemy", function(entity, other)
    if other:get_obstacle_behavior() == "flying" then
      return true
    else
      return false
    end
  end)
  sprite = burnable:get_sprite()
  sprite:set_animation("stopped")

end

burnable:add_collision_test("sprite", function(entity, other, entity_sprite, other_sprite)
  if sprite:get_animation() == "stopped" then
    if other:get_type() == "custom_entity" then
      if other:get_model() == "fire" or other:get_model() == "fire_rod_projo" then
        local el
        if map:is_obscure() then
          require("scripts/fsa_effect")
          el = create_light(burnable:get_map(),-256,-256,0,"80","193,185,100")
          el:set_position(burnable:get_position())
        end
        sprite:set_animation("burning")
        sol.timer.start(burnable, 1000, function()
          sol.audio.play_sound("lamp")
          local x2, y2, layer2 = burnable:get_position()
          y2 = y2+4
          x2 = x2+8
          for i = 0, 3 do
            if i == 1 then x2 = x2-16 end
            if i == 2 then y2 = y2-16 end
            if i == 3 then x2 = x2+16 end
            map:create_custom_entity{
              model = "fire",
              x = x2,
              y = y2,
              layer = layer2,
              width = 16,
              height = 16,
              direction = 0,
            }
          end
          if map:is_obscure() then
            sol.timer.start(400, function() el:set_enabled(false) end)
          end
          local sx, sy, sl = burnable:get_position()
          map:create_pickable({ layer = sl, x = sx, y = sy, treasure_name = entity:get_property("treasure"), treasure_variant = entity:get_property("variant") or 1 })
          burnable:remove()
          if burnable:get_property("on_destroyed") then burnable:on_destroyed() end
        end)
      end
    end
  end

end)