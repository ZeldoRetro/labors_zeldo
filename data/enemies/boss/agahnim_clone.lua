--Agahnim boss: A Dark Wizard, chief of the monsters and controlled by Ganon

local enemy = ...

local nb_sons_created = 0
local initial_life = 1
local finished = false
local vulnerable = false
local sprite

-- Possible positions where he appears.
local map = enemy:get_map()
local position_1_x, position_1_y = map:get_entity("agahnim_position_1"):get_position()
local position_2_x, position_2_y = map:get_entity("agahnim_position_2"):get_position()
local position_3_x, position_3_y = map:get_entity("agahnim_position_3"):get_position()
local position_4_x, position_4_y = map:get_entity("agahnim_position_4"):get_position()
local position_5_x, position_5_y = map:get_entity("agahnim_position_5"):get_position()
local position_6_x, position_6_y = map:get_entity("agahnim_position_6"):get_position()
local position_7_x, position_7_y = map:get_entity("agahnim_position_7"):get_position()
local position_8_x, position_8_y = map:get_entity("agahnim_position_8"):get_position()
local positions = {
  {x = position_1_x, y = position_1_y, direction4 = 3},
  {x = position_2_x, y = position_2_y, direction4 = 0},
  {x = position_3_x, y = position_3_y, direction4 = 2},
  {x = position_4_x, y = position_4_y, direction4 = 1},
  {x = position_5_x, y = position_5_y, direction4 = 1},
  {x = position_6_x, y = position_6_y, direction4 = 3},
  {x = position_7_x, y = position_7_y, direction4 = 3},
  {x = position_8_x, y = position_8_y, direction4 = 1},
}

function enemy:on_created()

  self:set_life(initial_life)
  self:set_damage(1)
  self:set_can_attack(false)
  self:set_optimization_distance(0)
  self:set_invincible()
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)

  sprite =  self:create_sprite("enemies/boss/agahnim_clone")
end

function enemy:on_custom_attack_received(attack, sprite)
  local hero = enemy:get_map():get_hero()
  if attack == "sword" then
    enemy:get_game():remove_life(7)
    hero:start_hurt(1)
    hero:freeze()
    hero:set_animation("electrocuted")
    sol.audio.play_sound("hero_hurt")
    sol.timer.start(1000, function () hero:unfreeze() end)
  end
end

function enemy:on_restarted()

  vulnerable = false
    sol.timer.start(self, 100, function()
      sprite:fade_out(function() self:hide() end)
    end)
end

function enemy:hide()
  vulnerable = false
  self:set_position(-100, -100)
  sol.timer.start(self, math.random(400,800), function() self:unhide() end)
end

function enemy:unhide()
  local position = (positions[math.random(#positions)])
  self:set_position(position.x, position.y)
  sprite:set_animation("walking")
  sprite:set_direction(position.direction4)
  sprite:fade_in()
  sol.timer.start(self, 1000, function() self:fire_step_1() end)
end

function enemy:fire_step_1()

  sprite:set_animation("arms_up")
  sol.timer.start(self, 1000, function() self:fire_step_2() end)
end

function enemy:fire_step_2()
  sprite:set_animation("preparing_fireball")
  sol.audio.play_sound("boss_charge")
  sol.timer.start(self, 1500, function() self:fire_step_3() end)
end

function enemy:fire_step_3()

  local sound, breed
  sound = "boss_fireball"
  breed = "boss/agahnim_red_fireball_3"
  sprite:set_animation("stopped")
  sol.audio.play_sound(sound)

  vulnerable = true
  sol.timer.start(self, 1300, function() self:restart() end)

  local function throw_fire()

    nb_sons_created = nb_sons_created + 1
    self:create_enemy{
      name = "agahnim_fireball_" .. nb_sons_created,
      breed = breed,
      direction = math.random(0,3),
      x = 0,
      y = -13
    }
  end

  throw_fire()
  sol.timer.start(self, 150, function() throw_fire() end)
  sol.timer.start(self, 300, function() throw_fire() end)
end

function enemy:receive_bounced_fireball(fireball)

  if fireball:get_name():find("^agahnim_fireball")
      and vulnerable then
    -- Receive a fireball shot back by the hero: get hurt.
    sol.timer.stop_all(self)
    fireball:remove()
    self:hurt(1)
  end
end