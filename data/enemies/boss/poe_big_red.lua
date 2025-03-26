local enemy = ...
local max_fire_created = 8   -- Maximum for a step.
local nb_fire_created = 0     -- In the current step.
local total_fire_created = 0  -- Total on all steps.
local attacks = 0

-- Big Poe: Larger ghost boss composed of smaller Poes, which
-- disappears occasionally and throws fire from its lantern.

function enemy:on_created()
  self:set_life(24); self:set_damage(8)
  self:create_sprite("enemies/boss/poe_big_red")
  self:set_size(32, 40); self:set_origin(16, 36)
  self:set_hurt_style("boss")
  self:set_push_hero_on_sword(false)
  self:set_layer_independent_collisions(true)
  self:set_obstacle_behavior("flying")
  self:set_invincible()
  self:set_visible(false)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(56)
  m:start(self)

  local life = enemy:get_life()
  if life <= 6 then max_fire_created = 20
  elseif life > 6 and life <= 12 then max_fire_created = 16
  elseif life > 12 and life <= 18 then max_fire_created = 12
  end

  nb_fire_created = 0
  sol.timer.start(self, 2000, function()
    self:stop_movement()
    --local sprite = self:get_sprite()
    --sprite:set_animation("preparing_fire")
    if attacks == 3 then
      sol.timer.start(self, 500, function() self:repeat_fire() end)
      attacks = 0
    else
      attacks = attacks + 1
      local angle = enemy:get_angle(enemy:get_map():get_hero():get_center_position())
      local son = self:create_enemy{
        breed = "flame_purple",
        x = 0,
        y = -8,
      }
      son:go(angle)
      sol.audio.play_sound("lamp")
        sol.timer.start(son,1100,function()
          local x, y, layer = son:get_position()
          self:get_map():create_pickable{
           	x = x,
           	y = y,
          	layer = layer,
            treasure_name = "pickable/random_heart_magic"
          }
        end)
      enemy:restart()
    end
  end)
end

function enemy:repeat_fire()

  if nb_fire_created < max_fire_created then
    nb_fire_created = nb_fire_created + 1
    total_fire_created = total_fire_created + 1
    local son_name = self:get_name() .. "_son_" .. total_fire_created
    local angle_start = 2 * math.pi / 4
    local angle_end = 9 * math.pi / 4
    local angle = angle_start + nb_fire_created * (angle_end - angle_start) / max_fire_created
    local son = self:create_enemy{
      name = son_name,
      breed = "flame_purple",
      x = 0,
      y = -8
    }
    son:go(angle)
    sol.audio.play_sound("lamp")
    sol.timer.start(self, 150, function() self:repeat_fire() end)
  else
    sol.timer.start(self, 500, function() self:restart() end)
  end
end

function enemy:on_hurt()
  local x,y = enemy:get_map():get_entity("boss_spot_"..math.random(5)):get_position()
  sol.timer.start(300, function() enemy:set_position(x,y) end)
end

function enemy:on_dying()

end