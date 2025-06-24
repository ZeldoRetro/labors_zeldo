local chest_meta=sol.main.get_metatable("chest")
require("scripts/multi_events")

chest_meta:register_event("on_created", function(chest)
    local game = chest:get_game()
    local hero = game:get_hero()
    local name = chest:get_name()
    
    -- An opened chest is ALWAYS visible
    if chest:is_open() then chest:set_enabled(true) end

    if name == nil then
        return
    end

    if name:match("^invisible_tile") then
        chest:set_visible(false)
    end
    if name:match("^invisible_path") then
        chest:set_visible(false)
    end

    if name:match("^dev_entity") then
        chest:set_visible(false)
    end

end)