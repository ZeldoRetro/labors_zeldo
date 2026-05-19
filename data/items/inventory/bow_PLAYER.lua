-- The bow has two variants: without arrows or with arrows.
-- This is necessary to allow it to have different icons in both cases.
-- Therefore, the light bow is implement as another item (bow_light),
-- and calls code from this bow.
-- It could be simpler if it was possible to change the icon of items dynamically.

local item = ...
local game = item:get_game()

function item:on_created()

  self:set_savegame_variable("possession_bow_PLAYER")
  self:set_assignable(true)
end

-- Using the bow.
-- This function can also be called by the light bow.
function item:on_using()

  -- item is the normal bow, self is the normal or the light one.

  local map = game:get_map()
  local hero = map:get_hero()

  hero:set_animation("bow")

  sol.timer.start(map, 200, function()
  sol.audio.play_sound("bow")
    self:set_finished()

    local x, y = hero:get_center_position()
    local _, _, layer = hero:get_position()
    local arrow = map:create_custom_entity({
      x = x,
      y = y,
      layer = layer,
      width = 16,
      height = 16,
      direction = hero:get_direction(),
      model = "arrow",
    })

    arrow:set_force(self:get_force())
    arrow:set_sprite_id(self:get_arrow_sprite_id())
    arrow:go()
  end)
end

function item:get_force()
  return 2
end

function item:get_arrow_sprite_id()

  return "entities/arrow_PLAYER"
end

-- Initialize the metatable of appropriate entities to work with custom arrows.
local function initialize_meta()

  -- Add Lua arrow properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_arrow_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.arrow_reaction = "force"
  enemy_meta.arrow_reaction_sprite = {}
  function enemy_meta:get_arrow_reaction(sprite)

    if sprite ~= nil and self.arrow_reaction_sprite[sprite] ~= nil then
      return self.arrow_reaction_sprite[sprite]
    end

    if self.arrow_reaction == "force" then
      -- Replace by the current force value.
      local game = self:get_game()
      return game:get_item("inventory/bow"):get_force()
    end

    return self.arrow_reaction
  end

  function enemy_meta:set_arrow_reaction(reaction, sprite)
    self.arrow_reaction = reaction
  end

  function enemy_meta:set_arrow_reaction_sprite(sprite, reaction)

    self.arrow_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account arrows.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_arrow_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_arrow_reaction_sprite(sprite, "ignored")
  end
end

initialize_meta()