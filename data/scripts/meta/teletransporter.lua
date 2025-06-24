local teletransporter_meta=sol.main.get_metatable("teletransporter")

teletransporter_meta:register_event("on_created", function(teletransporter)
  local game = teletransporter:get_game()
  local map = game:get_map()
  local hero = game:get_hero()

  -- Disable the teletransporter if the savegame value passed in property is false (teletransporter for miniboss/boss for example)
  if teletransporter:get_property("disable_if_no_value") ~= nil then
    if not game:get_value(teletransporter:get_property("disable_if_no_value")) then
      teletransporter:set_enabled(false)
    end
  end

  -- Disable the teletransporter if the savegame value passed in property is true (an opened door for example)
  if teletransporter:get_property("disable_if_value") ~= nil then
    if game:get_value(teletransporter:get_property("disable_if_value")) then
      if teletransporter:get_property("value_number") ~= nil then
        if game:get_value(teletransporter:get_property("disable_if_value")) == tonumber(teletransporter:get_property("value_number")) then teletransporter:set_enabled(false) end
      elseif teletransporter:get_property("amount_number") ~= nil then
        if game:get_value(teletransporter:get_property("disable_if_value")) >= tonumber(teletransporter:get_property("amount_number")) then teletransporter:set_enabled(false) end
      else teletransporter:set_enabled(false) end
    end
  end

  -- Enable the teletransporter if the savegame value passed in property is true
  if teletransporter:get_property("enable_if_value") ~= nil then
    if game:get_value(teletransporter:get_property("enable_if_value")) then
      if teletransporter:get_property("value_number") ~= nil then
        if game:get_value(teletransporter:get_property("enable_if_value")) == tonumber(teletransporter:get_property("value_number")) then teletransporter:set_enabled(true) end
      elseif teletransporter:get_property("amount_number") ~= nil then
        if game:get_value(teletransporter:get_property("enable_if_value")) >= tonumber(teletransporter:get_property("amount_number")) then teletransporter:set_enabled(true) end
      else teletransporter:set_enabled(true) end
    end
  end

end)

teletransporter_meta:register_event("on_activated", function(teletransporter)
    local game=teletransporter:get_game()
    local hero=game:get_hero()
    local ground=hero:get_ground_below()
    game:set_value("tp_destination", teletransporter:get_destination_name())
    game:set_value("tp_ground", ground) --save last ground for the ceiling drop manager

end)