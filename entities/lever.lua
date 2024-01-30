-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite = entity:get_sprite()
local lock_entity = false

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialized.
entity:register_event("on_created", function()
  
  entity:set_traversable_by(false)

  entity:add_collision_test("sprite", function(entity, other_entity, entity_sprite, other_entity_sprite)
    if other_entity:get_type()== "hero" and other_entity_sprite == other_entity:get_sprite("sword") and not lock_entity  then
      lock_entity = true
      if entity:get_property("state") == "1" then
        entity:set_property("state",0)
        sprite:set_animation("inactivated")
      else
        entity:set_property("state",1)
        sprite:set_animation("activated")
      end
      if entity.on_activated then
        entity:on_activated(entity)
      end
      sol.audio.play_sound("switch")
      sol.timer.start(entity, 500, function()
        lock_entity = false
      end)
    end
  end)

end)