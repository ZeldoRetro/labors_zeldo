local enemy = ...
local game = enemy:get_game()

local fly_proba = 20
local fly_fast = false
local nb_balls_created = 0

function enemy:on_created()

  self:set_life(12)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(48, 56)
  self:set_origin(24, 52)
  self:set_can_hurt_hero_running(true)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_invincible()
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_fire_reaction(4)
  self:set_hookshot_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", 2)
end

function enemy:on_restarted()

  if fly_fast then enemy:start_fly_fast_attack() return end

  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)

  sol.timer.start(self, math.random(1000,2500), function()
    m:stop()
    if math.random(100) <= fly_proba then
      self:start_fly_attack()
    else
      self:start_flame_attack()
    end
  end)
end

function enemy:start_flame_attack()
  local sprite = enemy:get_sprite()
  local hero = enemy:get_map():get_hero()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 240, function()
        if nb_balls_created == 0 then   sol.audio.play_sound("dinosaur") end
        if nb_balls_created < 8 then
          nb_balls_created = nb_balls_created + 1
          local angle_start = 3 * math.pi / 4
          local angle_end = 5 * math.pi / 4
          local angle = angle_start + nb_balls_created * (angle_end - angle_start) / 8
          local son = self:create_enemy{
            breed = "fireball_blue_small_circle",
            x = 0,
            y = -8,
            layer = 2
          }
          son:go(angle)
          return true
        else
          nb_balls_created = 0
          sol.timer.start(enemy, 1000, function()
            sprite:set_animation("walking")
            enemy:restart()
          end)
        end
  end)
end

function enemy:start_fly_attack()
  local sprite = enemy:get_sprite()
  local hero = enemy:get_map():get_hero()
  sprite:set_animation("fly")
  game:get_map():set_entities_enabled("aquamentus_flux_slow",true)
  sol.timer.start(enemy,5000,function()
    game:get_map():set_entities_enabled("aquamentus_flux_slow",false)
    enemy:restart()
  end)
end

function enemy:start_fly_fast_attack()
  local sprite = enemy:get_sprite()
  local hero = enemy:get_map():get_hero()
  sprite:set_animation("fly_fast")
  game:get_map():set_entities_enabled("aquamentus_flux_fast",true)
  sol.timer.start(enemy,3000,function()
    fly_fast = false 
    game:get_map():set_entities_enabled("aquamentus_flux_fast",false)
    enemy:restart()
  end)
end

function enemy:on_hurt()
  fly_proba = fly_proba + 5
  nb_balls_created = 0
  game:get_map():set_entities_enabled("aquamentus_flux_slow",false)
  game:get_map():set_entities_enabled("aquamentus_flux_fast",false)
  fly_fast = true 
end