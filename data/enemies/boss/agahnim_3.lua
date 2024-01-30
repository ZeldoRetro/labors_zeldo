--Agahnim boss: A Dark Wizard, chief of the monsters and controlled by Ganon

local enemy = ...

local nb_sons_created = 0
local initial_life = 8
local finished = false
local final_phase = false
local final_phase_ok = false
local blue_fireball_proba = 33  -- Percent.
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
local position_9_x, position_9_y = map:get_entity("agahnim_position_9"):get_position()
local position_10_x, position_10_y = map:get_entity("agahnim_position_10"):get_position()
local position_11_x, position_11_y = map:get_entity("agahnim_position_11"):get_position()
local position_12_x, position_12_y = map:get_entity("agahnim_position_12"):get_position()
local positions = {
  {x = position_1_x, y = position_1_y, direction4 = 3},
  {x = position_2_x, y = position_2_y, direction4 = 0},
  {x = position_3_x, y = position_3_y, direction4 = 2},
  {x = position_4_x, y = position_4_y, direction4 = 1},
  {x = position_5_x, y = position_5_y, direction4 = 1},
  {x = position_6_x, y = position_6_y, direction4 = 3},
  {x = position_7_x, y = position_7_y, direction4 = 3},
  {x = position_8_x, y = position_8_y, direction4 = 1},
  {x = position_9_x, y = position_9_y, direction4 = 0},
  {x = position_10_x, y = position_10_y, direction4 = 2},
  {x = position_11_x, y = position_11_y, direction4 = 0},
  {x = position_12_x, y = position_12_y, direction4 = 2},
}

function enemy:on_created()

  self:set_life(initial_life)
  self:set_damage(32)
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

  sprite =  self:create_sprite("enemies/boss/agahnim")
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

  if not final_phase then
    sprite:set_animation("stopped")
    sol.timer.start(self, 100, function()
      sprite:fade_out(function() self:hide() end)
    end)
  elseif final_phase_ok then
    sprite:set_animation("stopped")
    sol.timer.start(self, 100, function()
      sprite:fade_out(function() self:hide() end)
    end)
  else
    sprite:set_animation("hurt")
    self:get_map():get_entity("hero"):freeze()
    sol.timer.start(self, 100, function() self:end_dialog() end)
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
  if math.random(100) <= blue_fireball_proba then
    sound = "boss_fireball"
    breed = "boss/agahnim_blue_fireball_3"
  else
    sound = "boss_fireball"
    breed = "boss/agahnim_red_fireball_3"
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
  sol.timer.start(self, 150, function() throw_fire() end)
  sol.timer.start(self, 300, function() throw_fire() end)
  if self:get_life() <= initial_life / 2 then
    sol.timer.start(self, 450, function() throw_fire() end)
    sol.timer.start(self, 600, function() throw_fire() end)
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
    self:get_map():remove_entities("agahnim_clone")
    if not final_phase_ok then self:set_life(1) else enemy:on_dying() return end
    if not final_phase then final_phase = true end
  elseif life <= initial_life / 3 then
    blue_fireball_proba = 50
  end
  if final_phase_ok then
        self:create_enemy{
          name = "agahnim_clone_",
          breed = "boss/agahnim_clone",
          direction = 0,
          x = -1200,
          y = -1200,
          treasure_name = "pickable/heart"
        }
        self:create_enemy{
          name = "agahnim_clone_",
          breed = "boss/agahnim_clone",
          direction = 0,
          x = 1200,
          y = 1200,
          treasure_name = "pickable/heart"
        }
  end
end

function enemy:end_dialog()

  self:get_map():remove_entities("agahnim_fireball")
  sprite:set_ignore_suspend(true)
  if final_phase then
    final_phase_ok = true
    final_phase = false
    self:get_map():get_game():start_dialog("agahnim.3.escape",function()
      enemy:get_map():get_hero():unfreeze()
      enemy:set_life(4)
      enemy:restart()
      sol.timer.start(enemy,500,function()
        self:create_enemy{
          name = "agahnim_clone_",
          breed = "boss/agahnim_clone",
          direction = 0,
          x = -1200,
          y = -1200,
          treasure_name = "pickable/fairy"
        }
        self:create_enemy{
          name = "agahnim_clone_",
          breed = "boss/agahnim_clone",
          direction = 0,
          x = 1200,
          y = 1200,
          treasure_name = "pickable/fairy"
        }
      end)
    end)
  end
end

function enemy:on_dying()
  sol.audio.play_music("none")
end

function enemy:on_dead()
  local game = enemy:get_game()
  local hero = game:get_hero()
    game:set_value("labors_tott_wave_1_1_done",true)
    hero:freeze()
    game:set_pause_allowed(false)
    game:set_life(game:get_max_life())
    game:set_magic(game:get_max_magic())
    sol.audio.play_music("victory")
    sol.timer.start(8000,function() 
       hero:start_victory()
       sol.timer.start(1000,function()
    	  game:set_pause_allowed(true)
        hero:teleport("creations/labors/tott/hub","start_final_1","fade")
       end)     
    end)  
end