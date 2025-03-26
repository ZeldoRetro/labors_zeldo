local enemy = ...

-- Bubble: an invincible enemy that moves in diagonal directions
-- and bounces against walls.
-- It removes life and magic points from the hero, and remove his sword.

-- Directions note:
-- Right = South-East
-- Up = North-East
-- Left = North-West
-- Down = South-West

-- name of the savegame variable of the sword for this quest
local sword_save_string = "possession_sword"

-- item if magic powder used on the enemy (if an item is assigned to the enemy such as a door key, it will be replaced by the door key to avoid a potential softlock.)
local itinial_item_drop = "pickable/fairy"

-- if you want the "Gold" variant of the monster to be able to spawn. Note that if the enemy already has an assigned item such as a door key, it will never be modified to the "Gold" variant, therefore avoiding a potential softlock.
local gold_variant_spawning = false
-- the sprite ID of the star particule (you can ignore if gold_variant_spawning is "false")
local gold_particule_sprite = "entities/star"
-- The spawn probability of the “gold” variant of the entity. The higher the value, the rarer the variant will be. (you can ignore if gold_variant_spawning is "false")
local gold_spawn_probability = 30
-- The properties (ID, and Variant of the item) of the item dropped by the fire-fairy in "Gold" variant. (you can ignore if gold_variant_spawning is "false")
local gold_item_id, gold_item_variant = "pickable/rupee", 5



local map = enemy:get_map()
local game = enemy:get_game()
local last_direction8 = 0
local speed
local launch_timer_gold = false
local first_loading = true
local enemy_variant = enemy:get_property("variant")
if enemy_variant == nil then enemy_variant = "normal" end

local sword_level = game:get_ability("sword")

-- The enemy appears: set its properties.
function enemy:on_created()
  if enemy_variant == "blue" then
    speed = 80
    enemy:set_life(1)
    enemy:set_damage(1)
  elseif enemy_variant == "red" then
    speed = 80
    enemy:set_life(1)
    enemy:set_damage(1)
  else -- variant by default
    local treasure_name, treasure_variant, treasure_savegame = enemy:get_treasure()
    speed = 80
    enemy:set_life(1)
    enemy:set_damage(1)
  end
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_property("is_major","true")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_ice_reaction("custom")
  enemy:set_powder_reaction("custom")
end

-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  if first_loading then
    if (enemy_variant == "red") then
      enemy:get_sprite():set_animation("red")
    elseif (enemy_variant == "blue") then
      enemy:get_sprite():set_animation("blue")
    else
      enemy:get_sprite():set_animation("walking")
    end
    first_loading = false
  end

  if launch_timer_gold then
    launch_timer_gold = false
    sol.timer.start(enemy, 200, function()
      local x, y, layer = enemy:get_position()
      local star_particule = map:create_custom_entity({
        layer = math.max(layer+1, map:get_max_layer()),
        x = x+math.random(-8, 8),
        y = y+math.random(-12, 4),
        direction = 0,
        width = 8,
        height = 8,
        properties = {
              {
                key = "speed",
                value = "16",
              },
              {
                key = "angle_radiant",
                value = tostring(math.rad(90)),
              },
         },
         sprite = gold_particule_sprite,
      })
      local sprite = star_particule:get_sprite()
      sprite:set_animation(sprite:get_animation(), function()
        star_particule:remove()
      end)
      local movement = sol.movement.create("straight")
      movement:set_speed(16)
      movement:set_angle(math.rad(90))
      movement:start(star_particule)
      return true
    end)
  end

  local direction8 = enemy:get_sprite():get_direction()*2-1
  enemy:go(direction8)
end

-- An obstacle is reached: make the Bubble bounce.
function enemy:on_obstacle_reached()

  local dxy = {
    { x =  1, y =  0},
    { x =  1, y = -1},
    { x =  0, y = -1},
    { x = -1, y = -1},
    { x = -1, y =  0},
    { x = -1, y =  1},
    { x =  0, y =  1},
    { x =  1, y =  1}
  }

  -- The current direction is last_direction8:
  -- try the three other diagonal directions.
  local try1 = (last_direction8 + 2) % 8
  local try2 = (last_direction8 + 6) % 8
  local try3 = (last_direction8 + 4) % 8

  if not enemy:test_obstacles(dxy[try1 + 1].x, dxy[try1 + 1].y) then
    enemy:go(try1)
  elseif not enemy:test_obstacles(dxy[try2 + 1].x, dxy[try2 + 1].y) then
    enemy:go(try2)
  else
    enemy:go(try3)
  end
end

-- Makes the Bubble go towards a diagonal direction (1, 3, 5 or 7).
function enemy:go(direction8)

  local m = sol.movement.create("straight")
  m:set_speed(speed)
  m:set_smooth(false)
  m:set_angle(direction8 * math.pi / 4)
  m:start(self)
  last_direction8 = direction8
end

function enemy:catch_hero_check()
  if not map.hero_catched then
    hero_catch = true
    map.hero_catched = true
    sol.timer.start(map, 1000, function()
      map.hero_catched = nil
    end)
    return true
  end
end

-- Bubbles have a specific attack that drains magic.
function enemy:on_attacking_hero(hero)
  local game = enemy:get_game()

  if (enemy_variant == "red") then

    if game.bubble_blue_sword_disable then
      game:set_ability("sword", game:get_value(sword_save_string))
      game.bubble_red_sword_disable = nil
      game.bubble_blue_sword_disable = nil
      for sprite_name, sprite in hero:get_sprites() do
        sprite:set_color_modulation({255,255,255,255})
      end
    elseif not game.bubble_red_sword_disable then
      game:set_ability("sword", 0)
      game.bubble_red_sword_disable = true
      for sprite_name, sprite in hero:get_sprites() do
        sprite:set_color_modulation({255,75,50,255})
      end
    end

  elseif (enemy_variant == "blue") then

    if game.bubble_red_sword_disable then
      game:set_ability("sword", game:get_value(sword_save_string))
      game.bubble_blue_sword_disable = nil
      game.bubble_red_sword_disable = nil
      for sprite_name, sprite in hero:get_sprites() do
        sprite:set_color_modulation({255,255,255,255})
      end
    elseif not game.bubble_blue_sword_disable then
      game:set_ability("sword", 0)
      game.bubble_blue_sword_disable = true
      for sprite_name, sprite in hero:get_sprites() do
        sprite:set_color_modulation({50,75,255,255})
      end
    end

  elseif (enemy_variant == "normal") then
    if (not game.bubble_normal_sword_disable) and
    (not game.bubble_blue_sword_disable) and
    (not game.bubble_red_sword_disable) then
      game:set_ability("sword", 0)
      game.bubble_normal_sword_disable = true
      for sprite_name, sprite in hero:get_sprites() do
        sprite:set_color_modulation({125,125,125,255})
      end
      sol.timer.start(game, 3000, function()
        for sprite_name, sprite in hero:get_sprites() do
          sprite:set_color_modulation({255,255,255,255})
        end
        game:set_ability("sword", game:get_value(sword_save_string))
        game.bubble_normal_sword_disable = nil
      end)
    end

  end

  -- In any case, we do the hurt animation as usual
  hero:start_hurt(enemy, enemy:get_damage())

end

function enemy:on_custom_attack_received(attack, enemy_sprite)
  if (attack == "ice") then
    enemy:create_enemy({ breed = "bubble_white" })
    enemy:remove()
  elseif (attack == "powder") and (enemy_variant == "red") then
    speed = 80
    enemy_variant = "blue"
    enemy:get_sprite():set_animation("blue")
  elseif (attack == "powder") and (enemy_variant == "blue") then
    speed = 80
    enemy_variant = "red"
    enemy:get_sprite():set_animation("red")
  elseif (attack == "powder") then
    local x, y, layer = enemy:get_position()
    local explosion = map:create_custom_entity{
      x = x,
      y = y,
      layer = layer,
      width = 8,
      height = 8,
      direction = 0,
      sprite = "entities/transformation",
    }
    sol.audio.play_sound("cape_off")

    enemy:remove()

    sol.timer.start(map,500,function()
      local treasure_name, treasure_variant, treasure_savegame = enemy:get_treasure()
      local x_temp, y_temp, layer_temp = enemy:get_position()
      if (treasure_name ~= nil) then
        if (treasure_savegame_variable ~= nil) and (game:get_value(treasure_savegame_variable) == true) then
          return
        end
        map:create_pickable({
          treasure_name = treasure_name,
          treasure_variant = treasure_variant,
          treasure_savegame_variable = treasure_savegame,
          layer = layer_temp,
          x = x_temp,
          y = y_temp,
        })
        enemy:remove()
      else
        map:create_pickable({
          treasure_name = itinial_item_drop,
          treasure_variant = 1,
          treasure_savegame_variable = nil,
          layer = layer_temp,
          x = x_temp,
          y = y_temp,
        })
      end
    end)
  end
end