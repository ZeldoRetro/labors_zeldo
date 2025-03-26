-- Initialize destructibles behavior specific to this quest.

require("scripts/multi_events")

local destructible_meta = sol.main.get_metatable("destructible")
  
destructible_meta:register_event("on_created",function(destructible)

  local game = destructible:get_game()

  -- Set the pixel cut method for cutable destructibles
  destructible:set_cut_method("pixel")

  -- Disable the destructible if the savegame value passed in property is true (an opened secret hole for example)
  if destructible:get_property("disable_if_value") ~= nil then
    if game:get_value(destructible:get_property("disable_if_value")) then
      destructible:set_enabled(false)
    end
  end

  -- Enable the destructible if the savegame value passed in property is true
  if destructible:get_property("enable_if_value") ~= nil then
    if game:get_value(destructible:get_property("enable_if_value")) then
      if destructible:get_property("value_number") ~= nil then
        if game:get_value(destructible:get_property("enable_if_value")) == tonumber(destructible:get_property("value_number")) then destructible:set_enabled(true) end
      else destructible:set_enabled(true) end
    end
  end

  --DESTRUCTIBLES RULES

  -- Buissons: 2 Dégât + Trésor random Pickable
  if string.find(destructible:get_sprite():get_animation_set(), "entities/Bushes/") == 1 then
    if destructible:get_treasure() == nil and not destructible:get_property("disable_if_value") then destructible:set_treasure("pickable/random_pickable") end
    destructible:set_damage_on_enemies(2)
  end

  -- Pierres blanches: 4 Dégâts + Trésor random Standard
  if destructible:get_sprite():get_animation_set() == "entities/Destructables/stone_white"
  or destructible:get_sprite():get_animation_set() == "entities/Destructables/stone_white_skull" then
    if destructible:get_treasure() == nil and not destructible:get_property("disable_if_value") then destructible:set_treasure("pickable/random") end
    destructible:set_damage_on_enemies(4)
  end

  -- Pierres noires: 8 Dégâts + Trésor random Rubis
  if destructible:get_sprite():get_animation_set() == "entities/Destructables/stone_black"
  or destructible:get_sprite():get_animation_set() == "entities/Destructables/stone_black_skull" then
    if destructible:get_treasure() == nil and not destructible:get_property("disable_if_value") then destructible:set_treasure("pickable/random_rupees") end
    destructible:set_damage_on_enemies(8)
  end

  -- Vase (et crâne) standard: 2 Dégâts + Trésor random Pickable
  if destructible:get_sprite():get_animation_set() == "entities/Destructables/vase"
  or destructible:get_sprite():get_animation_set() == "entities/Destructables/vase_skull" then
    if destructible:get_treasure() == nil and not destructible:get_property("disable_if_value") then destructible:set_treasure("pickable/random_pickable") end
    destructible:set_damage_on_enemies(2)
  end

  -- Vase (et crâne) lourd: 4 Dégâts + Trésor random Standard
  if destructible:get_sprite():get_animation_set() == "entities/Destructables/vase_heavy"
  or destructible:get_sprite():get_animation_set() == "entities/Destructables/vase_skull_heavy" then
    if destructible:get_treasure() == nil and not destructible:get_property("disable_if_value") then destructible:set_treasure("pickable/random") end
    destructible:set_damage_on_enemies(4)
  end

  -- Vase (et crâne) très lourd: 8 Dégâts + Trésor random Rubis
  if destructible:get_sprite():get_animation_set() == "entities/Destructables/vase_very_heavy"
  or destructible:get_sprite():get_animation_set() == "entities/Destructables/vase_skull_black" then
    if destructible:get_treasure() == nil and not destructible:get_property("disable_if_value") then destructible:set_treasure("pickable/random_rupees") end
    destructible:set_damage_on_enemies(8)
  end

  local name = destructible:get_name()

  if name == nil then
    return
  end

  if name:match("^dev_entity") then
    destructible:set_visible(false)
  end
end)

destructible_meta:register_event("on_cut",function(destructible)
  destructible:on_lifting()  
end)

destructible_meta:register_event("on_lifting",function(destructible)

  local game = destructible:get_game()
  local map = game:get_map()
  local name = destructible:get_name()

  if name == nil then
    return
  end

  -- Destructibles cachant des trous ou accès secrets
  if name:match("^secret_bush_") then
    sol.audio.play_sound("secret")
    map:set_entities_enabled(destructible:get_name().."_ground", false)
    game:set_value(destructible:get_property("save_value"), true)
  end

  if name:match("^secret_stone_") then
    sol.audio.play_sound("secret")
    map:set_entities_enabled(destructible:get_name().."_ground", false)
    game:set_value(destructible:get_property("save_value"), true)
  end
end)
  
function destructible_meta:on_looked()
  local game = self:get_game()
  if self:get_can_be_cut()
    and not self:get_can_explode()
    and not self:get_game():has_ability("sword") then
    -- The destructible can be cut, but the player has no cut ability.
    game:start_dialog("destructible_cannot_lift_should_cut")
  elseif not game:has_ability("lift") then
    -- No lift ability at all.
    game:start_dialog("destructible_cannot_lift_too_heavy")
  else
    -- Not enough lift ability.
    game:start_dialog("destructible_cannot_lift_still_too_heavy")
  end
end