local chest_meta=sol.main.get_metatable("chest")
require("scripts/multi_events")

chest_meta:register_event("on_created", function(chest)
    local game = chest:get_game()
    local hero = game:get_hero()
    
    -- An opened chest is ALWAYS visible
    if chest:is_open() then chest:set_enabled(true) end

end)