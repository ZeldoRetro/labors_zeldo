local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  -- Rubis acheté au Marchand itinérant
  if game:get_value("rupees_10019_7") then shop_magic:set_enabled(true) end
end)

-- MARCHAND AMBULANT: BIENVENUE ET AUTRES
function shop_welcome:on_activated()
  self:set_enabled(false)
  game:start_dialog("shop.welcome_merchant")
end