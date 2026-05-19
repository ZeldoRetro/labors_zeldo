-- A ground of pikes where the hero is hurt when walking on it.

local pike_ground = ...

local allowed_states = {
  ["carrying"] = true,
  ["free"] = true,
  ["pulling"] = true,
  ["pushing"] = true,
  ["running"] = true,
  ["swimming"] = true,
  ["sword loading"] = true,
  ["sword spin attack"] = true,
  ["sword swinging"] = true,
  ["sword tapping"] = true,
}

function pike_ground:on_created()

  pike_ground:set_traversable_by(true)
  pike_ground:set_drawn_in_y_order(false)
  pike_ground:set_modified_ground("traversable")

end

pike_ground:add_collision_test("center", function(pike_ground, entity)

  if entity:get_type() ~= "hero" then
    return
  end

  local hero = entity
  local game = hero:get_game()

  if hero:is_invincible() then
    return
  end

  local current_state = hero:get_state()
  if not allowed_states[current_state] then
    return
  end

  game:remove_life(4)
  hero:set_blinking(true, 1000)
  hero:set_invincible(true, 1000)
  hero:on_taking_damage(0)
end)