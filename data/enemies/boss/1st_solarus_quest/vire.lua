local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()

-- Vire: Flying enemy which also creates and controls Keese

local going_hero = false
local timer

function enemy:on_created()
  self:set_life(8)
  self:set_damage(4)
  self:set_arrow_reaction(1)
  self:set_attack_consequence("sword", 1)
  self:create_sprite("enemies/boss/vire")
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(24, 16)
  self:set_origin(12, 13)
end

function enemy:on_restarted()
  local life = self:get_life() 
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("circle")
  m:set_center(hero, 0, 0)
  m:set_radius(48)
 	m:set_initial_angle(math.pi / 2)
 	m:set_angle_speed(80)
  m:set_ignore_obstacles(true)
 	m:start(self)
  going_hero = true  
end

function enemy:on_hurt()
  local life = self:get_life()

  if self:get_map():get_entities_count("keese_fire") <= 1 then
    if life ~= 0 then
    self:create_enemy({
      name = "keese_fire_",
      breed = "keese_fire",
      treasure_name = "pickable/random"
    })
    end
  end
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_circle()
  elseif not near_hero and going_hero then
    self:go_random()
  else
    local life = self:get_life()
    if self:get_map():get_entities_count("keese_fire") <= 1 then
      if life ~= 0 then
      self:create_enemy({
	name = "keese_fire_",
	breed = "keese_fire",
	treasure_name = "random"
      })
      end
    end
  end
  sol.timer.start(self:get_map(), 2000, function() self:check_hero() end)
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
  m:set_center(hero, 0, -20)
  m:set_radius(48)
  m:set_initial_angle(math.pi / 2)
  m:set_angle_speed(72)
  m:set_ignore_obstacles(true)
  m:start(self)
  going_hero = true
  end
end