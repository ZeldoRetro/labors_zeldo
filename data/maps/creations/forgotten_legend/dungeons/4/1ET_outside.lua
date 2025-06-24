local map = ...
local game = map:get_game()


--DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  --Blocs "raccourci" baissés
  if game:get_value("kokiri_shrine_shortcut_block_4_opened") then
    map:set_doors_open("kokiri_shrine_shortcut_block_2")
    kokiri_shrine_shortcut_block_2_switch:set_activated(true)
  end
end)

--RACCOURCI DE BLOCS
function kokiri_shrine_shortcut_block_2_switch:on_activated()
  local volume = sol.audio.get_sound_volume()
  sol.audio.set_sound_volume(0)
  map:open_doors("kokiri_shrine_shortcut_block_2")
  sol.audio.set_sound_volume(volume)
end