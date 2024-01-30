local entity = ...
local game = entity:get_game()
local lock_entity = false

-- Stone pile: a pile of stones which
-- can only be blown apart by a bomb or pegasus boots

function entity:on_created()
  local name = self:get_name()
  self:get_sprite()
  self:set_size(32, 32)
  self:set_origin(16, 29)
  self:set_traversable_by(false)
  self:add_collision_test("sprite", function(entity, other, entity_sprite, other_entity_sprite)
    ex, ey, el = entity:get_position()
    if other:get_type() == "explosion" and not lock_entity then
      lock_entity = true
      self:get_sprite():set_animation("destroy")
      entity:get_map():set_entities_enabled(name.."_ground",false)
      sol.timer.start(self, 500, function() self:remove() lock_entity = false end)
    elseif other:get_type() == "custom_entity" and not lock_entity then
      if other:get_model() == "explosion" then
        lock_entity = true
        self:get_sprite():set_animation("destroy")
        entity:get_map():set_entities_enabled(name.."_ground",false)
        sol.timer.start(self, 500, function() self:remove() lock_entity = false end)
      end
    elseif other:get_type() == "hero" and game:get_hero():get_state() == "running" and not lock_entity then
      lock_entity = true
      self:get_sprite():set_animation("destroy")
      entity:get_map():set_entities_enabled(name.."_ground",false)
      sol.timer.start(self, 500, function() self:remove() lock_entity = false end)
    end
  end)
end