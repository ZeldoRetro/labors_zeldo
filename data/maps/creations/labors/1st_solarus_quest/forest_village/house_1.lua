local map = ...
local game = map:get_game()

-- ACTIVER SWITCH DANS BIBLIO POUR SECRET
function npc_switch:on_interaction()
    sol.audio.play_sound("switch")
    if not game:get_value("rupees_10019_12") then npc_switch:set_enabled(false) auto_switch_auto_chest_rupees_1:on_activated() end
end