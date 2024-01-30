local behavior = {}

-- Behavior of a fixed enemy who shoots fireballs.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/lib/fire_breathing_statue")
-- local properties = {
--   sprite = "enemies/medusa",
--   projectile_breed = "fireball_small_triple_red",
--   projectile_sound = "zora",
--   detection_distance = 500,
--   shooting_delay = 1300,
--   fire_x = 0,
--   fire_y = 0,
-- }
-- behavior:create(enemy, properties)

local audio_manager = require("scripts/audio_manager")

function behavior:create(enemy, properties)

  local children = {}

  -- Set default properties.
  if properties.detection_distance == nil then
    properties.detection_distance = 500
  end
  if properties.shooting_delay == nil then
    properties.shooting_delay = 5000
  end
  if properties.fire_x == nil then
    properties.fire_x = 0
  end
  if properties.fire_y == nil then
    properties.fire_y = 0
  end

  function enemy:on_created()

    self:set_life(1)
    self:set_damage(0)
    self:create_sprite(properties.sprite)
    self:set_pushed_back_when_hurt(false)
    self:set_size(16, 16)
    self:set_origin(8, 13)
    self:set_can_attack(false)
    self:set_optimization_distance(1000)
    self:set_invincible()

    self:set_shooting(true)
  end

  function enemy:on_restarted()

    local map = enemy:get_map()
    local hero = map:get_hero()
    sol.timer.start(self, properties.shooting_delay, function()
      if not self.shooting then
        return true
      end

      if self:get_distance(hero) < properties.detection_distance and self:is_in_same_region(hero) then

        if not map.fire_breath_recent_sound then
          audio_manager:play_sound(properties.projectile_sound)
          -- Avoid loudy simultaneous sounds if there are several fire breathing enemies.
          map.fire_breath_recent_sound = true
          sol.timer.start(map, 200, function()
            map.fire_breath_recent_sound = nil
          end)
        end

        children[#children + 1] = self:create_enemy({
          breed = properties.projectile_breed,
          x = properties.fire_x,
          y = properties.fire_y,
          layer = map:get_max_layer()
        })
        children[#children]:set_layer_independent_collisions(true)
      end
      return true  -- Repeat the timer.
    end)
  end

  -- Suspends or restores shooting fireballs.
  function enemy:set_shooting(shooting)
    self.shooting = shooting
  end

  local previous_on_removed = self.on_removed
  function enemy:on_removed()

    if previous_on_removed then
      previous_on_removed(enemy)
    end

    for _, child in ipairs(children) do
      child:remove()
    end
  end

end

return behavior