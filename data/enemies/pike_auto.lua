local enemy = ...

-- Pike that always moves, horizontally or vertically
-- depending on its direction.

local recent_obstacle = 0

function enemy:on_created()

  self:set_life(1)
  enemy:set_damage(0)
  self:create_sprite("enemies/pike_detect")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_can_hurt_hero_running(true)
  self:set_obstacle_behavior("flying")
  self:set_property("is_major","true")
  self:set_invincible()
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
end

function enemy:on_restarted()

  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(120)
  m:set_loop(true)
  m:start(self)
end

function enemy:on_obstacle_reached()

  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  sprite:set_direction((direction4 + 2) % 4)

  local hero = self:get_map():get_hero()
  if recent_obstacle == 0 and self:is_in_same_region(hero) then
    sol.audio.play_sound("sword_tapping")
  end

  recent_obstacle = 8
  self:restart()
end

function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)

  if other_enemy:get_breed() == self:get_breed() then
    local sprite = self:get_sprite()
    local direction4 = sprite:get_direction()
    sprite:set_direction((direction4 + 2) % 4)

    local hero = self:get_map():get_hero()
    if recent_obstacle == 0 and self:is_in_same_region(hero) then
      sol.audio.play_sound("sword_tapping")
    end

    recent_obstacle = 8
    self:restart()
  end
end

function enemy:on_position_changed()

  if recent_obstacle > 0 then
    recent_obstacle = recent_obstacle - 1
  end
end

--Le dommage de l'ennemi sera de 4, quelle que soit la défense
enemy:register_event("on_attacking_hero", function(enemy)
  local hero = enemy:get_map():get_hero()
	enemy:get_game():remove_life(2)
  hero:start_hurt(enemy, 1)
end)