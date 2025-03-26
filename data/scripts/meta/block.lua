local block_meta=sol.main.get_metatable("block")
require("scripts/multi_events")

block_meta:register_event("on_created", function(block)
    local game = block:get_game()
    local hero = game:get_hero()
    
    if block:get_property("need_glove") ~= nil then
      if block:get_property("need_glove") == "1" then
        if game:get_ability("lift") < 1 then block:set_pushable(false) block:set_pullable(false) end
      elseif block:get_property("need_glove") == "2" then
        if game:get_ability("lift") < 2 then block:set_pushable(false) block:set_pullable(false) end
      elseif block:get_property("need_glove") == "3" then
        if game:get_ability("lift") < 3 then block:set_pushable(false) block:set_pullable(false) end
      end
    end

  -- Disable the block if the savegame value passed in property is true (a solved block puzzle for example)
  if block:get_property("disable_if_value") ~= nil then
    if game:get_value(block:get_property("disable_if_value")) then
      block:set_enabled(false)
    end
  end

  -- Enable the block if the savegame value passed in property is true (a solved block puzzle for example)
  if block:get_property("enable_if_value") ~= nil then
    if game:get_value(block:get_property("enable_if_value")) then
      block:set_enabled(true)
    end
  end

end)