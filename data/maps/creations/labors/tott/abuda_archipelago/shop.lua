local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
map:register_event("on_started", function(map, destination)
  --Coquillage acheté
   if game:get_value("shell_10006_1") then after_shell:set_enabled(true) end
end)

--DIALOGUE DE BIENVENUE DU MARCHAND
function trigger_dialog:on_activated() 
  self:set_enabled(false) 
  game:start_dialog("shop.welcome") 
end