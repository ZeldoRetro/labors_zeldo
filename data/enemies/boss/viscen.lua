-- Viscen: Soldier posseded by Ganon

local enemy = ...

local can_shoot = false

local quarter = math.pi * 0.5
local attacking = false

local distance_hero = 20

local movement
local sprite

local finished = false

-- Configuration variables
local waiting_duration = 2000
local second_thow_delay = 200
local falling_duration = 600
local falling_height = 16
local falling_angle = 3 * quarter - 0.4
local falling_speed = 100
local running_speed = 100

local projectile_initial_speed = 150

function enemy:on_created()

  enemy:set_life(16)
  enemy:set_damage(8)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_push_hero_on_sword(true)
  enemy:set_fire_reaction("protected")
  enemy:set_ice_reaction("protected")
  enemy:set_hookshot_reaction("protected")
  enemy:set_attack_consequence("thrown_item","protected")
  enemy:set_attack_consequence("boomerang","protected")
end

local function go_hero()

  sprite = enemy:get_sprite()
  sprite:set_animation("walking")
  movement = sol.movement.create("target")
  movement:set_speed(88)
  movement:start(enemy)
end

local function shoot()

  local sprite = enemy:get_sprite()

  enemy:stop_movement()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 250, function()
    sprite:set_animation("stopped")
    local projectile = enemy:create_enemy({breed = "bomb"})
    projectile:go(nil, nil, angle, projectile_initial_speed)

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

  if not finished then

    go_hero()

    if enemy:get_life() < 9 then can_shoot = true movement:set_speed(96) end 

    attacking = false
    enemy:check_hero()

    sol.timer.start(enemy, 100, function()

      local hero_x, hero_y = hero:get_position()
      local x, y = enemy:get_center_position()

      if can_shoot then
        local aligned = (math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16) 
        if aligned and enemy:get_distance(hero) < 200 and enemy:is_in_same_region(hero) then
          shoot()
          can_shoot = false
          sol.timer.start(enemy, 1500, function()
            can_shoot = true
          end)
        end
      end
      return true  -- Repeat the timer.
    end)

  else
    sprite:set_animation("final_hit")
    self:get_map():get_entity("hero"):freeze()
    sol.audio.play_music("none")
    sol.timer.start(self, 100, function() self:end_dialog() end)
  end
end

function enemy:attack()
  movement:stop()

  attacking = true
  sol.audio.play_sound("sword2")
  self:set_attack_consequence("sword","protected")
  sol.timer.start(enemy,70,function()
    --Seule l'Épée de Légende peut blesser Ganondorf
    self:set_attack_consequence("sword",1)
    self:get_sprite():set_animation("stopped")
  end)
  self:get_sprite():set_animation("sword")
  sol.timer.start(enemy,200,function()
    self:restart()
  end)
end

function enemy:check_hero()

  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < distance_hero

  if near_hero and not attacking then
    timer:stop()
    timer = nil
    enemy:attack()
  end

  timer = sol.timer.start(self, 100, function() self:check_hero() end)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_hurt(attack)

  local life = self:get_life()
  if life <= 0 then
    enemy:set_life(1)
    finished = true
  end
end

function enemy:end_dialog()
  enemy:get_game():set_pause_allowed(false)
  sprite:set_ignore_suspend(true)
  self:get_map():get_game():start_dialog("hyrule_city.hyrule_castle.viscen.boss.end",function()
    enemy:set_life(0)
    enemy:get_map():get_hero():unfreeze()
  end)
end