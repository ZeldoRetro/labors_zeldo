local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)
    -- Énigme de torches: chacune a une durée différente
    auto_timed_torch_auto_chest_rupees_1_4:set_duration(7000)
    auto_timed_torch_auto_chest_rupees_1_2:set_duration(5000)
    auto_timed_torch_auto_chest_rupees_1_3:set_duration(3000)
    auto_timed_torch_auto_chest_rupees_1_1:set_duration(2000)
end)