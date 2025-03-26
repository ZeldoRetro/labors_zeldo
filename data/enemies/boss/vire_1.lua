local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()

-- Vire

local going_hero = false
local timer
local dialog_done = false
local dialog_done_2 = false
local finished = false
local enabled = false

function enemy:on_created()
  self:set_life(15)
  self:set_damage(4)
  self:create_sprite("enemies/boss/vire")
  self:set_hurt_style("boss")
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(24, 16)
  self:set_origin(12, 13)
end

--Beginning of the fight
function enemy:on_enabled()
  enabled = true
  self:get_game():set_dialog_style("default")
  sol.timer.start(enemy:get_map():get_game(), 10, function() sol.audio.play_music("miniboss_2") end)
end

function enemy:on_restarted()

  if not finished then
    local life = self:get_life() 
    if life <= 10 and life > 5 then
    	local m = sol.movement.create("path_finding")
    	m:set_speed(72)
          m:start(self)
          self:check_hero()
    elseif life <= 5 then
    	local hero = self:get_map():get_entity("hero")
    	local m = sol.movement.create("circle")
    	m:set_center(hero, 0, 0)
    	m:set_radius(48)
   	  m:set_initial_angle(math.pi / 2)
   	  m:set_angle_speed(80)
    	m:set_ignore_obstacles(true)
   	  m:start(self)
    	going_hero = true  
    else
    local m = sol.movement.create("path_finding")
    m:set_speed(48)
    m:start(self)
    self:check_hero()
    end
  else
    self:get_sprite():set_animation("hurt")
    self:get_map():get_entity("hero"):freeze()
    sol.timer.start(self, 500, function() self:get_sprite():fade_out() end)
    sol.timer.start(self, 1000, function() self:escape() end)
  end
end

function enemy:on_hurt()
  local life = self:get_life()
  if life <= 0 then
    self:get_map():remove_entities("keese")
    self:set_life(1)
    finished = true
    self:get_sprite():set_ignore_suspend(true)
    sol.audio.play_music("none")
    self:get_map():get_game():start_dialog("vire.1.end")
    self:restart()
  elseif life <= 10 and life > 5 then
    if not dialog_done_2 then
    	game:start_dialog("vire.1.phase_1")
      dialog_done_2 = true
    end
  elseif life <= 5 then
    if not dialog_done then
    	game:start_dialog("vire.1.phase_2")
      dialog_done = true
    end
  end
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    local life = self:get_life()
    if finished == true then return end
    if enabled and self:is_in_same_region(hero) and self:get_map():get_entities_count("keese_") <= 1 then
      if life ~= 0 then
        sol.timer.start(enemy,100,function()
          self:create_enemy({
          	name = "keese_",
          	breed = "keese_fire",
            treasure_name = "pickable/random_heart_magic"
          })
        end)
      end
    end
  sol.timer.start(self:get_map(), 500, function() self:check_hero() end)
end

function enemy:go_random()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("circle")
  m:set_radius(48)
  m:set_radius_speed(56)
  m:start(self)
  going_hero = false
end

function enemy:go_circle()
  local life = self:get_life()
  if life ~= 0 then
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("circle")
  m:set_center(hero, 0, 0)
  m:set_radius(48)
  m:set_initial_angle(math.pi / 2)
  m:set_angle_speed(72)
  m:set_ignore_obstacles(true)
  m:start(self)
  going_hero = true
  end
end

function enemy:escape()
  self:get_map():get_game():set_value("vire_phase_1", true)
  self:remove()
  sol.audio.play_sound("correct")
  sol.timer.start(self:get_map(),1000,function()
    local x, y = enemy:get_map():get_entity("din_pearl_spot"):get_position()
    map:create_pickable{
      treasure_name = "quest_items/din_pearl_1",
      treasure_variant = 1,
      treasure_savegame_variable = "get_din_pearl_1",
      x = x,
      y = y,
      layer = 1
    }
    self:get_map():get_hero():unfreeze()
  end)
end