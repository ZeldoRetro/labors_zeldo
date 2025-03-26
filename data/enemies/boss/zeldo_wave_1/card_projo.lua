-- Lua script of enemy character/razer/razer_projectile.
-- This script is executed every time an enemy with this model is created.

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local projo_mode = tonumber(enemy:get_property("mode"))
local angle_movement = tonumber(enemy:get_property("angle"))
local frame_time_live = 0
local var_calcul_1 = 0

local var_2 = tonumber(enemy:get_property("var_2"))

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_invincible()
  enemy:set_hookshot_reaction("ignored")
  enemy:set_ice_reaction("ignored")
  enemy:set_fire_reaction("ignored")
  enemy:set_powder_reaction("ignored")
  enemy:set_life(1)
  enemy:set_damage(2)
  if var_2 ~= nil then
    if var_2 <= 1 then
      enemy:set_damage(8)
    end
  end
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  --enemy:set_minimum_shield_needed(2)
  if projo_mode == 1 then
    
  elseif projo_mode == 2 then
    var_calcul_1 = 360
    sol.timer.start(map, 4000, function()
      if enemy:exists() then
        enemy:remove()
      end
    end)
  elseif projo_mode == 3 then
    enemy:set_size(16, 16)
    enemy:set_origin(8, 11)
    sol.timer.start(map, 1000, function()
      if enemy:exists() then
        enemy:remove()
      end
    end)
  elseif projo_mode == 4 then
    enemy:set_can_attack(false)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 11)
    sol.timer.start(map, 8000, function()
      if enemy:exists() then
        enemy:remove()
      end
    end)
  end
  --print(enemy:get_name())
end

function enemy:on_restarted()
  movement = sol.movement.create("straight")
  movement:set_speed(128)
  if projo_mode == 1 then
    movement:set_speed(128)
    movement:set_angle(math.rad(angle_movement))
    sol.timer.start(enemy, 50, function()
      enemy:restart()
    end)
  elseif projo_mode == 2 then
    movement:set_speed(128)
    movement:set_angle(math.rad( math.ceil((angle_movement+var_calcul_1)%360) ))
    sol.timer.start(enemy, 50, function()
      enemy:restart()
    end)
  elseif projo_mode == 3 then
    if sprite:get_animation() ~= "fire" then
      sprite:set_direction(1)
      sprite:set_animation("fire")
    end
    movement:set_speed(0)
  elseif projo_mode == 4 then
    if sprite:get_animation() ~= "water" then
      sprite:set_direction(0)
      sprite:set_animation("water")
    end
    movement:set_speed(0)
    sol.timer.start(map, 500, function()
      if enemy:exists() then
        enemy:set_can_attack(true)
      end
    end)
  end
  movement:set_smooth(false)
  movement:start(enemy)
  function movement:on_obstacle_reached()
    if projo_mode == 1 then
      enemy:remove()
    elseif projo_mode == 2 then
      enemy:restart()
    end
  end
end

function enemy:on_update()
  if projo_mode == 1 then
    
  elseif projo_mode == 2 then
    var_calcul_1 = math.max(1, var_calcul_1*1.0025)
  end
  frame_time_live = frame_time_live+1
end

function enemy:on_pre_draw()
  if projo_mode == 1 then
    sprite:set_rotation((frame_time_live/8)%360)
  elseif projo_mode == 2 then
    sprite:set_rotation((frame_time_live/8)%360)
  end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  if var_2 ~= nil then
    if var_2 <= 1 then
      sol.timer.start(map, 20, function()
        hero:set_invincible(false)
        hero:set_blinking(false)
      end)
    end
  end
  local x_1, y_1 = enemy:get_position()
  if projo_mode == 4 then
    if enemy_sprite == nil then
      hero:start_hurt(enemy, enemy:get_damage()*2)
    else
      hero:start_hurt(enemy, enemy_sprite, enemy:get_damage()*2)
    end
    return
  end
  if (sol.main.get_distance( x_1, y_1, hero:get_position()) < 6) or (projo_mode == 3) then
    if enemy_sprite == nil then
      hero:start_hurt(enemy, enemy:get_damage())
    else
      hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
    end
    enemy:remove()
  end
end