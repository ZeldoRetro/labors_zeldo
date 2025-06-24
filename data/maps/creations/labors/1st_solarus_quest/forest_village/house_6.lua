local map = ...
local game = map:get_game()

local npc_repeat = false

function npc:on_interaction()
    if npc_repeat then
        game:start_dialog("LABORS.forest_village.guide_repeat")
    else
        game:start_dialog("LABORS.forest_village.guide")
        npc_repeat = true
    end
end