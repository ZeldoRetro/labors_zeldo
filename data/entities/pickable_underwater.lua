-- Lua script of custom entity pickable_sink.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local item, variant, savegame_variable
local timer

require("scripts/multi_events")
-- Event called when the custom entity is initialized.

entity:register_event("on_created", function(entity)
    -- Initialize the properties of your custom entity here,
    -- like the sprite, the size, and whether it can traverse other
    -- entities and be traversed by them.
    local item_name=entity:get_property("treasure_name")
    item=item_name and game:get_item(item_name) or nil
    variant=tonumber(entity:get_property("treasure_variant")) or 1
    savegame_variable=entity:get_property("treasure_savegame_variable")

    if savegame_variable~=nil and game:get_value(savegame_variable) then
      entity:remove()
      return
    end

    entity:get_sprite():set_animation(item_name)
    if item:get_can_disappear() then --Self-destroy after 10 seconds
      --TODO add blinking effect 
      timer=sol.timer.start(entity, 10000, function()
          entity:remove()
        end)
    end

    entity:add_collision_test("touching", function(entity, other)

        if other:get_type()=="hero" and (entity:get_map():is_sideview() or other:get_state()=="custom" and other:get_state_object():get_description()=="diving") then
          if item.on_obtaining then item:on_obtaining(variant, savegame_variable) end
          if item:get_brandish_when_picked() then
            other:start_treasure(item_name, variant, savegame_variable, function()
                other:unfreeze()
              end)
          else
            if item.on_obtained then
              item:on_obtained(variant, savegame_variable)
            end
          end
          entity:remove()
        end

      end)
    local visible=true
    entity:register_event("on_draw", function()
        if timer and timer:get_remaining_time() <= 3000 then
          visible=not visible
          entity:set_visible(visible)
        end
      end)
  end)


