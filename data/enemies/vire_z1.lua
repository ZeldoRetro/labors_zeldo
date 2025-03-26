-- Lua script of enemy vire.

local enemy = ...

local id_of_the_keese = "keese"

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local shadow_sprite = sol.sprite.create("enemies/" .. enemy:get_breed())
local sprite
local movement
local speed = 16
local x, y, layer = enemy:get_position()
local random_angle = 0
local random_distance = 0

function enemy:on_created()
  enemy:set_invincible_sprite(shadow_sprite)
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(8)
  enemy:set_damage(4)
  enemy:set_obstacle_behavior("normal")
  enemy:set_attacking_collision_mode("overlapping")
end

-- lerp(a, b, t) function
-- a = First value
-- b = Second value
-- t = pourcentage (100 = 1, 10% = 0.1, 1% = 0.01)
-- With this function you can find the value that equates to the position between two other values for a given percentage.
-- Useful for example to make the chain of a chain chomp.
-- Thanks to MelonSpeedruns for this usefull function

local function lerp(a, b, t)
  return a + (b - a) * t
end

function enemy:on_restarted()
  shadow_sprite:set_animation("shadow")
  shadow_sprite:set_opacity(0)
  if enemy:is_immobilized() then return end
  enemy:set_can_attack(true)
  x, y, layer = enemy:get_position()
  enemy:set_obstacle_behavior("normal")
  sol.timer.start(enemy, 1000, function()
    random_angle = math.rad(math.random(0,360))
    random_distance = math.random(64, 128)
    local have_a_good_position = nil
    for i = 1, 8 do
      if have_a_good_position == nil then
        local have_collision = nil
        local distance_calcul_test = random_distance/16

        for j = 1, distance_calcul_test do
          if enemy:test_obstacles(lerp(0, math.cos(random_angle+math.rad(45*i))*random_distance, j/distance_calcul_test), lerp(0, math.sin(random_angle+math.rad(45*i))*random_distance, j/distance_calcul_test)) then
            have_collision = true
          end
        end

        if have_collision == nil then
          have_a_good_position = true
        end
      end
      if have_a_good_position == true then
        random_angle = random_angle+math.rad(45*i)
        have_a_good_position = false
      end
    end
    if have_a_good_position == nil then
      enemy:set_obstacle_behavior("normal")
      local timer_num = 0
      sol.timer.start(enemy, 1000/speed, function()
        if timer_num < 5 then
          if not enemy:test_obstacles(math.cos(random_angle)*1, math.sin(random_angle)*1) then
            x = x+math.cos(random_angle)*1
            y = y+math.sin(random_angle)*1
            enemy:set_position(x, y, layer)
          end
          timer_num = timer_num+1
          return true
        else
          enemy:restart()
          return
        end
      end)
    else
      shadow_sprite:set_opacity(255)
      enemy:set_obstacle_behavior("flying")
      sprite:set_animation("jump")
      enemy:set_can_attack(false)
      local first_x, first_y = x, y
      local timer_num = 0
      sol.timer.start(enemy, 100/speed, function()
        timer_num = timer_num+1
        --if not enemy:test_obstacles((lerp(0, math.cos(random_angle)*random_distance, timer_num/100)), (lerp(0,math.sin(random_angle)*random_distance, timer_num/100))) then
          x = (lerp(first_x, first_x+math.cos(random_angle)*random_distance, timer_num/100))
          y = (lerp(first_y, first_y+math.sin(random_angle)*random_distance, timer_num/100))
          enemy:set_position(x, y+((math.abs(timer_num-50)-50)*1.2), layer)
        --else
        --  enemy:restart()
        --  sprite:set_animation("stopped")
        --end
        if timer_num < 100 then
          return true
        else
          enemy:restart()
          sprite:set_animation("stopped")
        end
      end)
    end
  end)
end

function enemy:on_immobilized(attack)
  shadow_sprite:set_opacity(0)
  sol.timer.stop_all(enemy)
  enemy:set_obstacle_behavior("normal")
end

function enemy:on_hurt(attack)
  shadow_sprite:set_opacity(0)
  sol.timer.stop_all(enemy)
  enemy:set_obstacle_behavior("normal")
  if enemy:get_life() > 0 then
    sol.timer.start(map, 300, function()
      enemy:remove()
      enemy:create_enemy({
        breed = id_of_the_keese,
        x = -8,
        y = -8,
        layer = layer,
        direction = 0
      })
      enemy:create_enemy({
        breed = id_of_the_keese,
        x = 8,
        y = -8,
        layer = layer,
        direction = 0
      })
    end)
  end
end

function enemy:on_pre_draw()
  map:draw_visual(shadow_sprite, x, y)
end