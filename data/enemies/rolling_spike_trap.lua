local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

function enemy:on_created()

  enemy:set_size(128, 16)
  enemy:set_origin(64, 13)
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible()
  self:set_obstacle_behavior("flying")

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_restarted()
  local direction_initial
  if enemy:get_sprite():get_direction() == 0 then
    direction_initial = 0
    enemy:set_size(16, 128)
    enemy:set_origin(8, 69)
  elseif enemy:get_sprite():get_direction() == 1 then
    direction_initial = (math.pi / 2)
    enemy:set_size(128, 16)
    enemy:set_origin(64, 13)
  elseif enemy:get_sprite():get_direction() == 2 then
    direction_initial = (math.pi)
    enemy:set_size(16, 128)
    enemy:set_origin(8, 69)
  elseif enemy:get_sprite():get_direction() == 3 then
    direction_initial = (3 * math.pi / 2)
    enemy:set_size(128, 16)
    enemy:set_origin(64, 13)
  end
  movement = sol.movement.create("straight")
  movement:set_angle(direction_initial)
  movement:set_speed(64)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    movement:set_angle(movement:get_angle()-math.rad(180))
    enemy:get_sprite():set_direction( (enemy:get_sprite():get_direction()-2)%4 )
    local hero = enemy:get_map():get_hero()
    if enemy:is_in_same_region(hero) then
      sol.audio.play_sound("sword_tapping")
    end
  end

  movement:start(enemy)
end

--Le dommage de l'ennemi sera de 4, quelle que soit la défense
enemy:register_event("on_attacking_hero", function(enemy)
  local hero = enemy:get_map():get_hero()
	enemy:get_game():remove_life(2)
  hero:start_hurt(enemy, 1)
end)