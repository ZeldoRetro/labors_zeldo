----------------------------------
--
-- A carriable bomb entity that can be thrown and explode after some time.
-- Reset the timer each time the bomb is carried.
--
----------------------------------

-- Global variables.
local bomb = ...

-- FOR ZELDA 1 STYLE BOMBS, JUST COMMENT THESE 2 LINES
local carriable_behavior = require("entities/lib/carriable")
carriable_behavior.apply(bomb, {bounce_sound = "hero_lands", slowdown_ratio = 0.2, is_offensive = false})


local carrying_state = require("scripts/states/carrying.lua")
local carrying = false

local map = bomb:get_map()
local sprite = bomb:get_sprite()
local exploding_timer, blinking_timer

--RAZDARAC FIX

local on_a_stream = nil
bomb:set_follow_streams(false)

function bomb:launch_this_collision()
 bomb:add_collision_test("center", function(entity, other)
  if other:get_type() == "stream" then
    if on_a_stream == nil then
      local m = sol.movement.create("path")
      m:set_speed(other:get_speed())
      m:set_path({other:get_direction()})
      function m:on_obstacle_reached()
        bomb:clear_collision_tests()
        on_a_stream = nil
        bomb:launch_this_collision()
      end
      m:start(bomb, function()
        bomb:clear_collision_tests()
        on_a_stream = nil
        bomb:launch_this_collision()
      end)
      on_a_stream = true
    end
  end
 end)
end
bomb:launch_this_collision()

bomb:register_event("on_finish_throw", function(carriable, direction)
  on_a_stream = nil
  bomb:launch_this_collision()
end)

bomb:register_event("on_thrown", function(carriable, direction)
  on_a_stream = nil
  bomb:clear_collision_tests()
end)

-- Configuration variables.
local countdown_duration = tonumber(bomb:get_property("countdown_duration")) or 2500
local blinking_duration = 1000

--Cette partie ici a ete ajoutee par DarkDavy15. Utilisez-le pour faire fonctionner l'ia du Dodongo.

-- Collision with a Dodongo when mouth open 
bomb:add_collision_test("sprite", function(entity, other, entity_sprite, other_sprite)
--check if is enemy
  if other:get_type() == "enemy" then


    -- begin of DODONGO param
    if other:get_breed() == "boss/dodongo" then

      -- Make the bomb explode.
      local function explode()
        sol.timer.start(bomb, 1, function()
          local x, y, layer = bomb:get_position()
          map:create_custom_entity({
            model = "explosion",
            direction = 0,
            x = x,
            y = y - 5,
            layer = layer,
            width = 16,
            height = 16,
            properties = {
              {key = "explosive_type_1", value = "crystal"},
              {key = "explosive_type_2", value = "destructible"},
              {key = "explosive_type_3", value = "door"},
             {key = "explosive_type_4", value = "enemy"},
             {key = "explosive_type_5", value = "sensor"}
            }
          })
          bomb:remove()
        end)
      end

    --print(other_sprite:get_animation_set())
    -- if bomb is in mouth
      if other_sprite:get_animation_set() == "enemies/boss/dodongo_head" then
            --Ma fonction
        if other:get_sprite():get_animation() == "open_mouth" then
          sol.timer.start(bomb, 1, function()
            bomb:remove()
            other:gobble_bomb_start()
          end)
        end
      end
      -- if bomb is on fire
      if other_sprite:get_animation_set() == "enemies/boss/dodongo_fire" then
        explode()
      end
    end -- end of DODONGO param
  end -- end of check enemy

end)

-- fin du script ajoutee.

-- Make the bomb explode.
local function explode()

  local x, y, layer = bomb:get_position()
  if carrying then y = y - 5 - 16 else y = y - 5 end
  map:create_custom_entity({
    model = "explosion",
    direction = 0,
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    properties = {
      {key = "explosive_type_1", value = "crystal"},
      {key = "explosive_type_2", value = "destructible"},
      {key = "explosive_type_3", value = "door"},
      {key = "explosive_type_4", value = "enemy"},
      {key = "explosive_type_5", value = "custom_entity"},
    }
  })
  sol.audio.play_sound("explosion")
  bomb:remove()
end

-- Start the countdown before explosion.
local function start_countdown()
    exploding_timer = sol.timer.start(bomb, countdown_duration, function()
      explode()
    end)
    blinking_timer = sol.timer.start(bomb, math.max(0, countdown_duration - blinking_duration), function()
      blinking_timer = nil
      sprite:set_animation("stopped_explosion_soon")
    end)
end

-- Stop the exploding timer on carrying.
bomb:register_event("on_carrying", function(bomb)
  carrying = true
end)

-- Restart the bomb timer before exploding on thrown.
bomb:register_event("on_bounce", function(bomb, direction)
  carrying = false
end)

-- Setup traversable rules and start the bomb timer before exploding.
bomb:register_event("on_created", function(bomb)
  sol.audio.play_sound("bomb")
  start_countdown()
end)