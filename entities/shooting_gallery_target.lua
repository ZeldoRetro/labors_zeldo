-- A minecart to be used by the hero on railroads.

local target = ...
local map = target:get_map()
local game = target:get_game()
local hero = map:get_hero()

target:set_traversable_by(true)
target:set_follow_streams(true)

local touched = false

-- Detect minecart stops.
target:add_collision_test("overlapping", function(target, other)

  if other:get_type() == "custom_entity" then

    if other:get_model() == "arrow" then
      if not touched then
        touched = true
        target:set_follow_streams(false)
        target:get_sprite():set_animation("disappear",function() target:remove() end)
        sol.audio.play_sound("shooting_gallery_bell")
      end
    end

  end

end)
