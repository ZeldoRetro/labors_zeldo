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

end)

teletransporter_meta:register_event("on_activated", function(teletransporter)
    local game=teletransporter:get_game()
    local hero=game:get_hero()
    local ground=hero:get_ground_below()
    game:set_value("tp_destination", teletransporter:get_destination_name())
    game:set_value("tp_ground", ground) --save last ground for the ceiling drop manager

end)