-- Lua script of enemy peahat.
local enemy = ...
require("scripts/multi_events")
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local shadow_sprite = sol.sprite.create("enemies/" .. enemy:get_breed())
local tornado_sprite = sol.sprite.create("enemies/" .. enemy:get_breed())
local sprite = {}
local state
local speed
local z = 0
local random_angle = 0

function enemy:on_created()
  state = 0
  speed = 4
  enemy:set_obstacle_behavior("flying")
  shadow_sprite:set_animation("shadow")
  tornado_sprite:set_animation("tornado")
  tornado_sprite:set_opacity(0)
  sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed())
  sprite[2] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_immobilized")
  sprite[2]:set_opacity(0)
  enemy:set_life(8)
  enemy:set_damage(4)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_can_attack(false)
end

function enemy:on_restarted()
 if state == 0 then
  enemy:set_can_attack(false)
  sol.timer.stop_all(enemy)
  enemy:set_invincible()
  shadow_sprite:set_opacity(255)
  sprite[1]:set_animation("fly_1")
  sol.timer.start(enemy, 1000, function()
    sprite[1]:set_animation("fly_2")
    enemy:set_can_attack(true)
    tornado_sprite:set_opacity(255)
  end)
  random_angle = math.rad(math.random(0,360))
  if enemy:test_obstacles(math.cos(random_angle)*16, math.sin(random_angle)*16) then
    if not enemy:test_obstacles(16, 0) then
      random_angle = math.rad(0)
    elseif not enemy:test_obstacles(0, -16) then
      random_angle = math.rad(270)
    elseif not enemy:test_obstacles(-16, 0) then
      random_angle = math.rad(180)
    elseif not enemy:test_obstacles(0, 16) then
      random_angle = math.rad(90)
    end
  end
  local timer_num_1 = 0
  local end_timer_random = math.random(128, 1024)
  local temp_x, temp_y = enemy:get_position()
  sol.timer.start(enemy, 20, function()
    timer_num_1 = timer_num_1+1
    local speed_multiplier = math.min(64, ((timer_num_1/50)*(timer_num_1/3)))
    if (timer_num_1%4) == 0 then
      local c_normal_spd = speed*(speed_multiplier/100)
      
      if not enemy:test_obstacles(math.cos(random_angle)*speed, math.sin(random_angle)*speed) then
        if not enemy:test_obstacles(math.cos(random_angle)*c_normal_spd, math.sin(random_angle)*c_normal_spd) then
          temp_x, temp_y = temp_x+(math.cos(random_angle)*c_normal_spd), temp_y+(math.sin(random_angle)*c_normal_spd)
        else
          temp_x, temp_y = temp_x+(math.cos(random_angle)*speed), temp_y+(math.sin(random_angle)*speed)
        end
      elseif not enemy:test_obstacles(0, math.sin(random_angle)*speed) then
        if not enemy:test_obstacles(0, math.sin(random_angle)*c_normal_spd) then
          temp_y = temp_y+(math.sin(random_angle)*c_normal_spd)
        else
          temp_y = temp_y+(math.sin(random_angle)*speed)
        end
      elseif not enemy:test_obstacles(math.cos(random_angle)*speed, 0) then
        if not enemy:test_obstacles(math.cos(random_angle)*c_normal_spd, 0) then
          temp_x = temp_x+(math.cos(random_angle)*c_normal_spd)
        else
          temp_x = temp_x+(math.cos(random_angle)*speed)
        end
      else
        if not enemy:test_obstacles(math.min(1, math.cos(random_angle)*2), math.min(1, math.sin(random_angle)*2)) then
          temp_x, temp_y = temp_x+(math.min(1, math.cos(random_angle)*2)), temp_y+(math.min(1, math.sin(random_angle)*2))
        elseif not enemy:test_obstacles(0, math.min(1, math.sin(random_angle)*2)) then
          temp_y = temp_y+(math.min(1, math.sin(random_angle)*2))
        elseif not enemy:test_obstacles(math.min(1, math.cos(random_angle)*2), 0) then
          temp_x = temp_x+(math.min(1, math.cos(random_angle)*2))
        end
      end
      enemy:set_position(temp_x, temp_y)
    end

    if (speed_multiplier >= 64) and (sprite[1]:get_animation() == "fly_2") then
      sprite[1]:set_animation("fly_3")
    end
    sprite[1]:set_xy(   0, -speed_multiplier-(math.sin(timer_num_1/15)*16)   )
    if timer_num_1 < end_timer_random then
      return true
    else
      tornado_sprite:set_opacity(0)
      enemy:set_can_attack(false)
      sprite[1]:set_animation("fly_1")
      local timer_num_2 = 0
      local temp_x, temp_y = 0, -10
      sol.timer.start(enemy, 20, function()
        temp_x, temp_y = sprite[1]:get_xy()
        timer_num_2 = timer_num_2+1
        if temp_y < 0 then
          sprite[1]:set_xy(   0, (-speed_multiplier-(math.sin(timer_num_1/15)*16))+ ((timer_num_2/50)*(timer_num_2/3))   )
          return true
        else
          enemy:set_can_attack(true)
          sprite[1]:set_animation("stopped")
          sprite[1]:set_xy(0, 0)
          shadow_sprite:set_opacity(0)
          enemy:set_attack_consequence("sword", 1)
          enemy:set_attack_consequence("thrown_item", 2)
          enemy:set_arrow_reaction(2)
          enemy:set_fire_reaction(2)
          enemy:set_ice_reaction(2)
          enemy:set_hookshot_reaction("immobilized")
          enemy:set_hammer_reaction(4)
          enemy:set_attack_consequence("boomerang", "immobilized")
          enemy:set_attack_consequence("explosion", 2)
          sol.timer.start(enemy, end_timer_random*5, function()
            enemy:restart()
          end)
        end
      end)
    end
  end)
 elseif state == 1 then
  tornado_sprite:set_opacity(0)
  enemy:set_can_attack(false)
  shadow_sprite:set_opacity(0)
  enemy:set_default_attack_consequences()
 end
end

function enemy:on_immobilized(attack)
  state = 1
  sprite[1]:set_opacity(0)
  sprite[2]:set_opacity(255)
  sol.timer.stop_all(enemy)
  enemy:set_obstacle_behavior("normal")
  enemy:set_can_attack(false)
end

function enemy:on_pre_draw()
  map:draw_visual(shadow_sprite, enemy:get_position())
  map:draw_visual(tornado_sprite, enemy:get_position())
end

map:register_event("on_draw", function(map, dst_surface)
  if enemy:get_attack_consequence("sword") == "ignored" then
    sprite[1]:draw(dst_surface, enemy:get_position())
  end
end)