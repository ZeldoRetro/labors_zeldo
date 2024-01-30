local item = ...
local game = item:get_game()

function item:on_created()

  -- Define the properties.
  item:set_shadow("small")
  self:set_savegame_variable("possession_monicle_truth")
  self:set_assignable(true)
end

function item:on_using()

	local map = item:get_map()
  	local magic_needed = 1  -- Number of magic points required


	if game:get_value("monicle_active",true) then
		sol.audio.play_sound("monicle_off")
    for entity in map:get_entities("invisible_path") do
			entity:set_visible(false)
		end
    for entity in map:get_entities("invisible_tile") do
  	 entity:set_visible(false)
    end
    for entity in map:get_entities("invisible_enemy") do
    	entity:set_visible(false)
    end
		game:set_value("monicle_active",false)
	else
  		if self:get_game():get_magic() >= magic_needed then
   			sol.audio.play_sound("monicle_on")
      	for entity in map:get_entities("invisible_path") do
  				entity:set_visible(true)
  			end
      	for entity in map:get_entities("invisible_tile") do
  				entity:set_visible(true)
  			end
        for entity in map:get_entities("invisible_enemy") do
        	entity:set_visible(true)
        end
			 game:set_value("monicle_active",true)
  		else
    			sol.audio.play_sound("wrong")
          game:start_dialog("_need_magic")
  		end
	end
  	self:set_finished()
end

-- FONCTIONS PERMETTANT LE DRAINAGE DE MAGIE
function item:on_map_changed()
  game:set_value("monicle_active",false)
  game:set_value("magic_drained",false)
end
function item:on_update()
	local map = item:get_map()
  if game:get_value("monicle_active",true) then
    if not game:get_value("magic_drained") then
      game:set_value("magic_drained",true)
      sol.timer.start(2000,function() 
        game:remove_magic(1) 
        game:set_value("magic_drained",false)
      end)
    end
  end
  if game:get_magic() < 1 then
    for entity in map:get_entities("invisible_path") do
			entity:set_visible(false)
		end
    for entity in map:get_entities("invisible_tile") do
			entity:set_visible(false)
		end
    for entity in map:get_entities("invisible_enemy") do
    	entity:set_visible(false)
    end
		game:set_value("monicle_active",false)
  end
end