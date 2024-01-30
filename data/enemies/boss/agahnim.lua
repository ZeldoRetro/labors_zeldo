--Agahnim boss: A Dark Wizard, chief of the monsters and controlled by Ganon

local enemy = ...

local nb_sons_created = 0
local initial_life = 8
local finished = false
local blue_fireball_proba = 20  -- Percent.
local vulnerable = false
local sprite

-- Possible positions where he appears.
local map = enemy:get_map()
local position_1_x, position_1_y = map:get_entity("agahnim_position_1"):get_position()
local position_2_x, position_2_y = map:get_entity("agahnim_position_2"):get_position()
local position_3_x, position_3_y = map:get_entity("agahnim_position_3"):get_position()
local position_4_x, position_4_y = map:get_entity("agahnim_position_4"):get_position()
local positions = {
  {x = position_1_x, y = position_1_y, direction4 = 3},
  {x = position_2_x, y = position_2_y, direction4 = 0},
  {x = position_3_x, y = position_3_y, direction4 = 2},
  {x = position_4_x, y = position_4_y, direction4 = 1},
}

function enemy:on_created()

  self:set_life(initial_life)
  self:set_damage(8)
  self:set_hurt_style("boss")
  self:set_optimization_distance(0)
  self:set_invincible()
  self:set_attack_consequence("sword", "custom")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_fire_reaction("protected")
  self:set_ice_reaction("protected")
  self:set_hammer_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)

  sprite =  self:create_sprite("enemies/" .. enemy:get_breed())
end

--Beginning of the fight
function enemy:on_enabled()
  self:get_map():get_entity("agahnim_sprite"):set_enabled(false)
  self:get_game():set_dialog_position("bottom")
  self:get_game():set_dialog_position("auto")
  sol.timer.start(enemy:get_map():get_game(), 10, function() sol.audio.play_music("creations/forgotten_legend/agahnim_battle_1") end)
  self:get_map():get_game():start_dialog("agahnim.1.intro")
end

function enemy:on_custom_attack_received(attack, sprite)
  local hero = enemy:get_map():get_hero()
  if attack == "sword" then
    enemy:get_game():remove_life(3)
    hero:start_hurt(1)
    hero:freeze()
    hero:set_animation("electrocuted")
    sol.audio.play_sound("hero_hurt")
    sol.timer.start(1000, function () hero:unfreeze() end)
  end
end

function enemy:on_restarted()

  vulnerable = false

  if not finished then
    sprite:set_animation("stopped")
    sol.timer.start(self, 100, function()
      sprite:fade_out(function() self:hide() end)
    end)
  else
    sprite:set_animation("hurt")
    self:get_map():get_entity("hero"):freeze()
    sol.timer.start(self, 100, function() self:end_dialog() end)
    sol.timer.start(self, 500, function() sprite:fade_out() end)
    sol.timer.start(self, 1000, function() self:escape() end)
  end
end

function enemy:hide()
  vulnerable = false
  self:set_position(-100, -100)
  sol.timer.start(self, 500, function() self:unhide() end)
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
  if sprite:get_direction() == 3 then
    sound = "laser"
    breed = "boss/agahnim_lightning"
  elseif math.random(100) <= blue_fireball_proba then
    sound = "boss_fireball"
    breed = "boss/agahnim_blue_fireball"
  else
    sound = "boss_fireball"
    breed = "boss/agahnim_red_fireball"
  end
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
  if self:get_life() <= initial_life / 2 then
    sol.timer.start(self, 200, function() throw_fire() end)
    sol.timer.start(self, 400, function() throw_fire() end)
  end
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

function enemy:on_hurt(attack)

  local life = self:get_life()
  if life <= 0 then
    self:get_map():remove_entities("agahnim_fireball")
    self:set_life(1)
    finished = true
  elseif life <= initial_life / 3 then
    blue_fireball_proba = 33
  end
end

function enemy:end_dialog()

  self:get_map():remove_entities("agahnim_fireball")
  sprite:set_ignore_suspend(true)
  self:get_map():get_game():start_dialog("agahnim.1.escape")
end

function enemy:escape()
  self:get_game():set_value("miniboss_"..self:get_game():get_dungeon_index(),true)
  sol.audio.play_sound("correct")
  sol.timer.start(self:get_map(),1000,function()
    self:get_map():open_doors("door_miniboss")
    self:get_map():set_entities_enabled("telep_miniboss")
    sol.audio.play_music("creations/labors/tott/fire_temple")
    self:get_map():get_hero():unfreeze()
  end)
end