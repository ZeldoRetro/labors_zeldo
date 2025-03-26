local enemy = ...
local game = enemy:get_game()

local properties = {}
local going_hero = false
local main_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())

function enemy:on_created()

  self:set_life(2)
  self:set_damage(0)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_invincible()
end

function enemy:on_restarted()

    if going_hero then
      self:go_hero()
    else
    self:get_sprite():set_animation("stopped")
    self:check_hero()
    end
end

function enemy:check_hero()

  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 120

  if near_hero and not going_hero and self:is_in_same_region(hero) then
    sol.audio.play_sound("quadruplet_1_run")
    enemy:run_away()
  end
  sol.timer.stop_all(self)
  sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:run_away()
  local angle = enemy:get_angle(enemy:get_map():get_hero())
  angle = angle + math.pi
  movement = sol.movement.create("straight")
  movement:set_angle(angle)
  movement:set_speed(128)
  movement:start(enemy) 
end

function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    main_sprite:set_direction(direction4)
end

function enemy:on_movement_finished(movement)
    self:run_away()
end

function enemy:on_obstacle_reached(movement)
    self:run_away()
end

function enemy:go_hero()
  local movement = sol.movement.create("random_path")
  movement:set_speed(160)
  movement:start(self)
  going_hero = true
end