local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
  -- Clé 1 - Énigme de torches: chacune a une durée différente
  auto_timed_torch_auto_chest_key_1_1:set_duration(3000)
  auto_timed_torch_auto_chest_key_1_2:set_duration(200)
  auto_timed_torch_auto_chest_key_1_3:set_duration(5000)
  auto_timed_torch_auto_chest_key_1_4:set_duration(1500)
  
end)

-- SWITCHES TRIGGER EVENT

function switch_trigger_event_o:on_activated()
  hero:freeze()
  sol.audio.play_sound("correct")
  sol.timer.start(map, 700, function()
    hero:teleport(switch_trigger_event_o:get_property("tp_map"), switch_trigger_event_o:get_property("dest"))
  end)
end

function switch_trigger_event_e:on_activated()
  hero:freeze()
  sol.audio.play_sound("correct")
  sol.timer.start(map, 700, function()
    hero:teleport(switch_trigger_event_e:get_property("tp_map"), switch_trigger_event_e:get_property("dest"))
  end)
end

map:register_event("on_opening_transition_finished",function(map, destination)
  if destination == dest_switch_o then
    enemy_1:remove()
  end
  if destination == dest_switch_e then
    auto_enemy_auto_door_5_3:remove()
  end
end)