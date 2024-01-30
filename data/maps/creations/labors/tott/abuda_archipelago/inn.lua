local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:set_speed(32)
  movement:start(npc)
end

-- DEBUT DE LA MAP
function map:on_started()
  npc_walk(kitchen_woman)
  snores:set_enabled(false)
end

--INTERACTIONS AVEC L'AUBERGISTE
for npc in map:get_entities("aubergiste") do
  function npc:on_interaction()
    local price = 20
  	if game:get_value("get_inn_key") then
  		game:start_dialog("inn.good_stay")
  	else
  		game:start_dialog("inn.question",price,function(answer)
        if answer == 1 then
          if game:get_money() >= price then
            game:remove_money(price)
         	  game:start_dialog("inn.answer_yes", function()
              hero:start_treasure("other/inn_key", 1, "get_inn_key")
            end)
          else
            sol.audio.play_sound("wrong")
            game:start_dialog("inn.no_money")
          end
        else
          game:start_dialog("inn.answer_no")
        end
  		end)
  	end
  end
end

--AVERTISSEMENT AVANT DE QUITTER L'AUBERGE
function exit_sensor:on_activated()
  if game:get_value("get_inn_key") and not inn_room_door:is_open() then
    exit_sensor:set_enabled(false)
    game:start_dialog("inn.exit_warning")
  end
end

--ON PERD LA CLE EN SORTANT DE L'AUBERGE
function map:on_finished()
  game:set_value("get_inn_key",false)
end