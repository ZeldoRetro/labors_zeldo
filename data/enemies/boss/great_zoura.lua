-- The Great Zoura: Water Temple Miniboss

local enemy = ...
local sprite
local timer_fireballs = 500
local max_fireballs = 1
local nb_balls_created = 0
local proba = 100

-- Possible positions where he appears.
local map = enemy:get_map()
local position_1_x, position_1_y = map:get_entity("position_miniboss_1"):get_position()
local position_2_x, position_2_y = map:get_entity("position_miniboss_2"):get_position()
local position_3_x, position_3_y = map:get_entity("position_miniboss_3"):get_position()
local position_4_x, position_4_y = map:get_entity("position_miniboss_4"):get_position()
local position_5_x, position_5_y = map:get_entity("position_miniboss_5"):get_position()
local positions = {
  {x = position_1_x, y = position_1_y, direction4 = 0},
  {x = position_2_x, y = position_2_y, direction4 = 0},
  {x = position_3_x, y = position_3_y, direction4 = 0},
  {x = position_4_x, y = position_4_y, direction4 = 0},
  {x = position_5_x, y = position_5_y, direction4 = 0}
}

function enemy:on_created()

  enemy:set_life(12)
  enemy:set_damage(4)
  enemy:set_hurt_style("boss")
  enemy:set_obstacle_behavior("swimming")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_layer_independent_collisions(true)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  function sprite:on_animation_finished(animation)
    if animation == "shooting" then
      sprite:set_animation("walking")
    end
  end
end

function enemy:on_hurt(attack)
  sol.timer.stop_all(self)
  local life = self:get_life()
  if life == 1 then
    proba = 30
    max_fireballs = 10 timer_fireballs = 150
  elseif life <= 4 then
    proba = 50
    max_fireballs = 5 timer_fireballs = 300
  elseif life <= 8 then
    proba = 90
    max_fireballs = 3 timer_fireballs = 350
  end
end

function enemy:shoot()
  local i = 0
  sol.timer.start(enemy, timer_fireballs,function()
    i = i + 1
    sol.audio.play_sound("zora")
    sprite:set_animation("shooting")
    enemy:create_enemy({
      breed = "fireball_blue_small",
    })
    if i == max_fireballs then
      i = 0
      sol.timer.start(enemy, 1000, function()
        sprite:set_animation("walking")
        enemy:disappear()
      end)
    else return true end
  end) 
end

function enemy:appear()

  local sprite = enemy:get_sprite()
  local position = (positions[math.random(#positions)])
  self:set_position(position.x, position.y)
  enemy:set_visible(true)
  sprite:set_animation("underwater")
  sol.timer.start(enemy, 1000, function()
    if math.random(100) <= proba then
      enemy:set_can_attack(true)
      enemy:set_attack_consequence("boomerang", 1)
      enemy:set_attack_consequence("sword", 1)
      enemy:set_attack_consequence("explosion", 2)
      enemy:set_attack_consequence("thrown_item", 1)
      enemy:set_hookshot_reaction(2)
      enemy:set_fire_reaction(2)
      enemy:set_ice_reaction(2)
      enemy:set_arrow_reaction(2)
      enemy:set_hammer_reaction(4)
      sprite:set_animation("walking")
      if enemy:get_position() == enemy:get_map():get_entity("position_miniboss_1"):get_position() then 
        self:shoot_circle() 
      else
        sol.timer.start(enemy,500, function() enemy:shoot() end)
      end
    else enemy:disappear() end
  end)

end

function enemy:disappear()

  local hero = enemy:get_map():get_hero()
  local sprite = enemy:get_sprite()
  local direction = enemy:get_direction4_to(hero)
  sprite:set_direction(direction)
  enemy:set_invincible()
  enemy:set_can_attack(false)
  sprite:set_animation("underwater")
  sol.timer.start(enemy, 1000, function()
      enemy:set_visible(false)
      sol.timer.start(enemy, math.random(1000,3000), function()
        local direction = enemy:get_direction4_to(hero)
        local sprite = enemy:get_sprite()
        sprite:set_direction(direction)
        if enemy:is_in_same_region(hero) then 
          enemy:appear()
        else enemy:restart() end
      end)  
  end)

end

function enemy:shoot_circle()
  local sprite = enemy:get_sprite()
  local hero = enemy:get_map():get_hero()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 10, function()
        sol.audio.play_sound("zora")
        if nb_balls_created < 8 then
          nb_balls_created = nb_balls_created + 1
          local angle_start = 2 * math.pi / 4
          local angle_end = 9 * math.pi / 4
          local angle = angle_start + nb_balls_created * (angle_end - angle_start) / 8
          local son = self:create_enemy{
            breed = "fireball_blue_small_circle",
            x = 0,
            y = -8
          }
          son:go(angle)
          sol.timer.start(self, 150, function() self:shoot_circle() end)
        else
          nb_balls_created = 0
          sol.timer.start(enemy, 1000, function()
            sprite:set_animation("walking")
            enemy:disappear()
          end)
        end
  end)
end

function enemy:on_restarted()
  enemy:disappear()
end