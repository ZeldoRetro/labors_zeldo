local enemy = ...

-- Manhandla: Boss with multiple heads to attack. This file defines the head segments.

function enemy:on_created()
  self:set_life(8); self:set_damage(4)
  self:create_sprite("enemies/boss/manhandla_head")
  self:set_size(24, 24); self:set_origin(12, 12)
  self:set_push_hero_on_sword(true)
  self:set_invincible()
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("thrown_item", 2)
  self:set_attack_consequence("explosion", 2)
  self:set_arrow_reaction(2)
  self:set_hookshot_reaction(2)
  self:set_hammer_reaction(1)
  self:set_attack_consequence("boomerang", "protected")
end

function enemy:on_restarted()

  local map = enemy:get_map()
  local hero = map:get_hero()
  sol.timer.start(enemy, math.random(5000,10000), function()
    if enemy:get_distance(hero) < 500 and enemy:is_in_same_region(hero) then

      if not map.medusa_recent_sound then
        sol.audio.play_sound("dinosaur")
        -- Avoid loudy simultaneous sounds if there are several medusa.
        map.medusa_recent_sound = true
        sol.timer.start(map, 200, function()
          map.medusa_recent_sound = nil
        end)
      end

      enemy:create_enemy({
        breed = "boss/manhandla_ball",
        layer = 2
      })
    end
    return true  -- Repeat the timer.
  end)
end

function enemy:on_update()
  local body = self:get_map():get_entity("boss")
  local bx, by, bl = body:get_position()
  -- Keep the heads attached to the body!
  -- Each head color has a different position on the body.
  if self.color == "blue" then
    self:set_position(bx+35, by)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(0) end
  elseif self.color == "purple" then
    self:set_position(bx, by-35)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(1) end
  elseif self.color == "green" then
    self:set_position(bx-35, by)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(2) end
  elseif self.color == "red" then
    self:set_position(bx, by+35)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(3) end
  end
end

function enemy:on_dead()
  if self.color == "blue" then
    enemy:get_map():get_entity("wall_blue"):set_enabled(false)    
  elseif self.color == "purple" then
    enemy:get_map():get_entity("wall_purple"):set_enabled(false)
  elseif self.color == "green" then
    enemy:get_map():get_entity("wall_green"):set_enabled(false)    
  elseif self.color == "red" then
    enemy:get_map():get_entity("wall_red"):set_enabled(false)    
  end
end