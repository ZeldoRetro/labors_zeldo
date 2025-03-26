-- Viscen: Soldier posseded by Ganon

local enemy = ...

local can_shoot = true

local quarter = math.pi * 0.5
local attacking_timer = nil

-- Configuration variables
local waiting_duration = 5000
local second_thow_delay = 500
local falling_duration = 600
local falling_height = 16
local falling_angle = 3 * quarter - 0.4
local falling_speed = 100
local running_speed = 100

local map = enemy:get_map()
local goriya = map:get_entity("goriya_king")
local i = 1

function enemy:on_created()

  enemy:set_life(99)
  enemy:set_damage(8)
  enemy:set_pushed_back_when_hurt(false)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_can_attack(false)
  enemy:set_invincible()
end

local function go_hero()

  local sprite = enemy:get_sprite()
  sprite:set_animation("walking")
  local map = enemy:get_map()

  local movement = sol.movement.create("target")
  movement:set_target(goriya)
  movement:set_speed(88)
  movement:start(enemy)
end

local function shoot()

  local sprite = enemy:get_sprite()
  local direction = sprite:get_direction()
  local angle = direction * math.pi / 2

  enemy:stop_movement()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 500, function()
    sprite:set_animation("stopped")
    local projectile = enemy:create_enemy({breed = "ally/bomb"})
    projectile:go(250, nil, angle, 240)

    if on_throwed_callback then
      on_throwed_callback()
    end

    -- Call an enemy:on_enemy_created(projectile) event.
    if enemy.on_enemy_created then
      enemy:on_enemy_created(projectile)
    end

    enemy:restart()
  end)

end

function enemy:on_restarted()

  local map = enemy:get_map()
  local hero = map:get_hero()

  if goriya == nil then i = i + 1 end
  go_hero()

  sol.timer.start(enemy, 1000, function()
    can_shoot = true
  end)

  sol.timer.start(enemy, 100, function()

    local hero_x, hero_y = hero:get_position()
    local x, y = enemy:get_center_position()

    if can_shoot then
      local aligned = (math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16) 
      if aligned and enemy:get_distance(goriya) < 128 and enemy:is_in_same_region(hero) then
        shoot()
        can_shoot = false
      end
    end
    return true  -- Repeat the timer.
  end)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end