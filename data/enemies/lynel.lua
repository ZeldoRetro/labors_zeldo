-- Lua script of enemy lynel.
local enemy = ...


-- if you want the "Gold" variant of the monster to be able to spawn. Note that if the enemy already has an assigned item such as a door key, it will never be modified to the "Gold" variant, therefore avoiding a potential softlock.
local gold_variant_spawning = true
-- the sprite ID of the star particule (you can ignore if gold_variant_spawning is "false")
local gold_particule_sprite = "entities/star"
-- The spawn probability of the “gold” variant of the entity. The higher the value, the rarer the variant will be. (you can ignore if gold_variant_spawning is "false")
local gold_spawn_probability = 30
-- The properties (ID, and Variant of the item) of the item dropped by the fire-fairy in "Gold" variant. (you can ignore if gold_variant_spawning is "false")
local gold_item_id, gold_item_variant = "consumables/rupee", 6

local enemy_variant = enemy:get_property("variant")
if enemy_variant == nil then enemy_variant = "normal" end

local launch_timer_gold = false
local treasure_name, treasure_variant, treasure_savegame = enemy:get_treasure()




local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = {}
local x, y = enemy:get_position()
local speed = 8
local projectile_speed = 256
local projectile_damage = 8

local view_distance = 88
local targeted_hero = false
local target_cooldown = 0

 -- radians to degrees
-- for the opposite, use "math.rad" for degrees to radian
local function get_degrees(radians)
  return radians*(180/math.pi)
end

function enemy:on_created()
  if (math.random(1,gold_spawn_probability) == 1) and (treasure_name == nil) then
    enemy:set_treasure(gold_item_id, gold_item_variant, nil)
    sprite[0] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_golden")
    sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head_golden")
    enemy:set_life(32)
    enemy:set_damage(48)
    enemy_variant = "gold"
    launch_timer_gold = true

  elseif (enemy_variant == "green") then

    sprite[0] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_green")
    sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head_green")
    enemy:set_life(16)
    enemy:set_damage(4)

  elseif (enemy_variant == "blue") then

    sprite[0] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_blue")
    sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head_blue")
    enemy:set_life(20)
    enemy:set_damage(8)

  elseif (enemy_variant == "purple") then

    sprite[0] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_purple")
    sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head_purple")
    enemy:set_life(24)
    enemy:set_damage(12)

  elseif (enemy_variant == "grey") then

    sprite[0] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_grey")
    sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head_grey")
    enemy:set_life(128)
    enemy:set_damage(128)

  elseif (enemy_variant == "yellow") then

    sprite[0] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_yellow")
    sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head_yellow")
    enemy:set_life(16)
    enemy:set_damage(2)

  elseif (enemy_variant == "normal") then

    sprite[0] = enemy:create_sprite("enemies/" .. enemy:get_breed())
    sprite[1] = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_head")
    enemy:set_life(16)
    enemy:set_damage(2)

  end
  enemy:set_size(32, 32)
  enemy:set_origin(16, 29)
  enemy:set_attacking_collision_mode("overlapping")
  local stupid_function = sprite[0]
  function stupid_function:on_direction_changed(animation, direction)
    if direction == 0 then
      sprite[1]:set_xy(8, -34)
    elseif direction == 1 then
      sprite[1]:set_xy(0, -34)
    elseif direction == 2 then
      sprite[1]:set_xy(-8, -34)
    elseif direction == 3 then
      sprite[1]:set_xy(0, -34)
    else
      sprite[1]:set_xy(8, -34)
    end
  end
  if direction == 0 then
    sprite[1]:set_xy(8, -34)
  elseif direction == 1 then
    sprite[1]:set_xy(0, -34)
  elseif direction == 2 then
    sprite[1]:set_xy(-8, -34)
  elseif direction == 3 then
    sprite[1]:set_xy(0, -34)
  else
    sprite[1]:set_xy(8, -34)
  end
end

function enemy:seen_hero()
  targeted_hero = true
  target_cooldown = 100
end

function enemy:on_restarted()
  if launch_timer_gold then
    launch_timer_gold = false
    sol.timer.start(map, 200, function()
      if not enemy:exists() then return end
      local x, y, layer = enemy:get_position()
      local star_particule = map:create_custom_entity({
        layer = math.max(layer+1, map:get_max_layer()),
        x = x+math.random(-8, 8),
        y = y+math.random(-12, 4),
        direction = 0,
        width = 8,
        height = 8,
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
  x, y = enemy:get_position()
  local distance_h_and_m = sol.main.get_distance(x, y, hero:get_position())
  local angle_m_and_h = math.abs( get_degrees(sol.main.get_angle(x, y, hero:get_position())) )

  if target_cooldown <= 0 then
    targeted_hero = false
  end

  if targeted_hero then -- IA lorsque joueur ciblee
    sprite[0]:set_animation("walking")
    local attack_frequency = 100
    sol.timer.start(enemy, 10, function()
      attack_frequency = attack_frequency-1
      distance_h_and_m = sol.main.get_distance(x, y, hero:get_position())
      angle_m_and_h = sol.main.get_angle(x, y, hero:get_position())
      if distance_h_and_m > view_distance then
        target_cooldown = target_cooldown-1
      end
      if attack_frequency == 0 then
        sprite[0]:set_animation("attack")
        sol.timer.start(enemy, 1200/(speed/8), function()
          local beam = enemy:create_enemy({
            breed = "lynel_beam",
          })
          enemy:sound_play("boss_fireball")
          beam:set_speed(projectile_speed)
          beam:set_damage(projectile_damage)
          beam:go(sprite[0]:get_direction())
          enemy:restart()
        end)
      else
        for k, v in pairs(sprite) do
          v:set_direction(  enemy:get_direction4_to(hero:get_position())  )
        end
        local calcul_angle = random_angle
        if distance_h_and_m < 48 then -- Si heros trop proche, enemy s eloigne
          calcul_angle = angle_m_and_h-math.pi
        elseif distance_h_and_m > 88 then -- si heros trop loin, enemy s approche
          calcul_angle = angle_m_and_h
        else -- si la distance entre hero et enemy est correct, il essaie daller a la position hori ou verti parfait
          local temp_1, temp_2 = hero:get_position()
          local temp_x = {}
          local temp_y = {}
          local distance_prio = 5000
          local dir_prioritize
          temp_x[0], temp_y[0] = temp_1+64, temp_2
          temp_x[1], temp_y[1] = temp_1, temp_2-64
          temp_x[2], temp_y[2] = temp_1-64, temp_2
          temp_x[3], temp_y[3] = temp_1, temp_2+80
          for i = 0, 3 do
            if distance_prio > sol.main.get_distance(x, y, temp_x[i], temp_y[i]) then
              distance_prio = sol.main.get_distance(x, y, temp_x[i], temp_y[i])
              dir_prioritize = i
            end
          end
          if sol.main.get_distance(x, y, temp_x[dir_prioritize], temp_y[dir_prioritize]) <= 4 then
            return true
          end
          calcul_angle = sol.main.get_angle(x, y, temp_x[dir_prioritize], temp_y[dir_prioritize])
        end
        local calcul_speed = speed/8
        if not enemy:test_obstacles(math.cos(calcul_angle)*calcul_speed, -math.sin(calcul_angle)*calcul_speed) then
            x, y = x+(math.cos(calcul_angle)*calcul_speed), y-(math.sin(calcul_angle)*calcul_speed)
        elseif not enemy:test_obstacles(0, -math.sin(calcul_angle)*calcul_speed) then
            y = y-(math.sin(calcul_angle)*calcul_speed)
        elseif not enemy:test_obstacles(math.cos(calcul_angle)*speed, 0) then
            x = x+(math.cos(calcul_angle)*calcul_speed)
        end
        enemy:set_position(x, y)
        return true
      end
    end)

  else -- IA lorsque le monstre ne poursuit plus le joueur

    local choose_direction = math.ceil(math.random(0,3))
    local temp_x, temp_y = 0, 0
    local look_to_left, look_to_right = 0, 0
    if choose_direction == 0 then
      temp_x = 1
      look_to_left = 1
      look_to_right = 3
    elseif choose_direction == 1 then
      temp_y = -1
      look_to_left = 2
      look_to_right = 0
    elseif choose_direction == 2 then
      temp_x = -1
      look_to_left = 3
      look_to_right = 1
    else
      temp_y = 1
      look_to_left = 0
      look_to_right = 2
    end
    local timer_repeat = 0
    for k, v in pairs(sprite) do
      v:set_direction(  choose_direction  )
    end
    sol.timer.start(enemy, 10, function()
      timer_repeat = timer_repeat+1
      distance_h_and_m = sol.main.get_distance(x, y, hero:get_position())
      angle_m_and_h = math.abs( get_degrees(sol.main.get_angle(x, y, hero:get_position())) )
      if distance_h_and_m <= view_distance then 
        if angle_m_and_h > 45 and angle_m_and_h <= 135 then
          -- Haut
          if sprite[1]:get_direction() == 1 then
            enemy:seen_hero()
            enemy:restart()
          end
        elseif angle_m_and_h > 135 and angle_m_and_h <= 225 then
          -- Gauche
          if sprite[1]:get_direction() == 2 then
            enemy:seen_hero()
            enemy:restart()
          end
        elseif angle_m_and_h > 225 and angle_m_and_h <= 315 then
          -- Bas
          if sprite[1]:get_direction() == 3 then
            enemy:seen_hero()
            enemy:restart()
          end
        else
          -- Droite
          if sprite[1]:get_direction() == 0 then
            enemy:seen_hero()
            enemy:restart()
          end
        end
      end
      
      if timer_repeat <= 100 and timer_repeat%4 == 0 then
        if not sprite[0]:get_animation() == "walking" then sprite[0]:set_animation("walking") end
        if not enemy:test_obstacles(0+(temp_x*(speed/8)), 0+(temp_y*(speed/8))) then
          x, y = x+(temp_x*(speed/8)), y+(temp_y*(speed/8))
        elseif not enemy:test_obstacles(0+(temp_x), 0+(temp_y)) then
          x, y = x+(temp_x), y+(temp_y)
        end
      elseif timer_repeat > 150 and timer_repeat <= 200 then
        if not sprite[0]:get_animation() == "stopped" then sprite[0]:set_animation("stopped") end
        sprite[1]:set_direction(look_to_left)
      elseif timer_repeat > 200 and timer_repeat <= 250 then
        sprite[1]:set_direction(sprite[0]:get_direction())
      elseif timer_repeat > 250 and timer_repeat <= 300 then
        sprite[1]:set_direction(look_to_right)
      elseif timer_repeat > 300 and timer_repeat <= 350 then
        sprite[1]:set_direction(sprite[0]:get_direction())
      elseif timer_repeat > 450 then
        enemy:restart()
      end
      enemy:set_position(x, y)
      return true
    end)

  end
end

function enemy:on_immobilized(hero, enemy_sprite)
  enemy:seen_hero()
end

function enemy:on_hurt(hero, enemy_sprite)
  enemy:seen_hero()
end