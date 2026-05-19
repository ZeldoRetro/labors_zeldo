-- Lua script of enemy bosses/zeldo/gold_arrow.
local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local repeat_arrow

function enemy:on_created()
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", 1)
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_dying_sprite_id("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage( tonumber(enemy:get_property("damage")) ~= nil and tonumber(enemy:get_property("damage")) or 1 )
  enemy:set_size(8,8)
  enemy:set_origin(4,4)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_obstacle_behavior("flying")
  repeat_arrow = enemy:get_property("repeat")
  repeat_arrow = tonumber(repeat_arrow)
  if repeat_arrow ~= nil then
    sprite:set_color_modulation({60, 255-(repeat_arrow*25), 255/repeat_arrow, 255})
  end
end

function enemy:on_restarted()
  if movement ~= nil then movement:stop() end
  local angle = enemy:get_angle(hero:get_center_position())
  local speed = tonumber(enemy:get_property("speed")) ~= nil and tonumber(enemy:get_property("speed")) or 180
  movement = sol.movement.create("straight")
  movement:set_speed(speed)
  movement:set_angle(angle)
  movement:set_ignore_obstacles(true)
  movement:set_max_distance(repeat_arrow ~= nil and 64 + (64 / repeat_arrow) or 480)
  sprite:set_rotation(angle+(math.pi/2))
  movement:set_smooth(false)
  function movement:on_obstacle_reached()
    enemy:remove()
    local x, y, layer = enemy:get_position()
    local particule = enemy:get_map():create_custom_entity({
      layer = layer,
      x = x,
      y = y,
      direction = 2,
      width = 8,
      height = 8,
      sprite = "enemies/" .. enemy:get_breed(),
    })
    particule:get_sprite():set_animation("killed", function()
      particule:remove()
    end)
  end
  movement:start(enemy, function()
    if repeat_arrow ~= nil and repeat_arrow > 0 then
      local x, y, layer = enemy:get_position()
      map:create_enemy({
        breed = "boss/zeldo_wave_2/gold_arrow",
        layer = layer,
        x = x,
        y = y-2,
        direction = 0,
        treasure_name = "pickable/random_arrows",
        treasure_variant = 1,
        properties = {
          {
            key = "speed",
            value = tostring(speed * 1.15),
          },
          {
            key = "damage",
            value = tostring(enemy:get_damage()),
          },
          {
            key = "repeat",
            value = tostring(repeat_arrow-1),
          },
        },
      })
    end
    enemy:remove()
  end)
end

function enemy:on_pre_draw(camera)
  sprite:set_scale(math.random(0.9,1.1)*(1-(math.random(0,1)*2))  ,  math.random(0.9,1.1))
end