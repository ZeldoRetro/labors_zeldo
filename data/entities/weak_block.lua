local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local lock_entity = false

-- Weak blobk : need bombs to blow them up.

-- Tell the hookshot that it can hook to us.
function entity:is_hookable()
  return true
end

function entity:on_created()
  local name = self:get_name()
  self:get_sprite()
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_traversable_by(false)
  self:add_collision_test("sprite", function(entity, other, entity_sprite, other_entity_sprite)
    if other:get_type() == "custom_entity" and not lock_entity then
      if other:get_model() == "explosion" then
        lock_entity = true
        self:get_sprite():set_animation("opening")
        if entity:get_property("on_destroyed") then entity:on_destroyed() end
        local sx, sy, sl = entity:get_position()
        map:create_pickable({ layer = sl, x = sx, y = sy, treasure_name = entity:get_property("treasure"), treasure_variant = entity:get_property("variant") or 1 })
        entity:set_traversable_by(true)
        sol.timer.start(self, 500, function() self:remove() lock_entity = false end)
      end
    end
  end)
end