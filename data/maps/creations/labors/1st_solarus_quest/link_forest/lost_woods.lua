local map = ...
local game = map:get_game()

--BACKGROUND ARBRES
local trees = sol.surface.create("backgrounds/trees.png")

map:register_event("on_draw",function(map,dst_surface)
  trees:draw(dst_surface)
end)


-- GUIDE QUI NOUS INVITE À TROUVER ÉPÉE ET BOUCLIER
function guide_foret:on_interaction()

	if not game:get_value("get_shield_10011") then
		game:start_dialog("LABORS.1st_solarus_quest.link_forest.forest_guide_cant_pass")
	else
		game:start_dialog("LABORS.1st_solarus_quest.link_forest.forest_guide_pass")
	end
end

-- COFFRES VIDES
function chest_empty_1:on_opened()
	sol.audio.play_sound("treasure_bad")
	game:start_dialog("_empty_chest")
	hero:unfreeze()
end

-- BOIS PERDUS: ON TOURNE EN ROND...
local function send_hero(sensor_1, sensor_2)
	local hero_x, hero_y = hero:get_position()
	local sensor_1_x, sensor_1_y = sensor_1:get_position()
	local sensor_2_x, sensor_2_y = sensor_2:get_position()

	hero_x = hero_x + sensor_2_x - sensor_1_x
	hero_y = hero_y + sensor_2_y - sensor_1_y
	hero:set_position(hero_x, hero_y)
end

function lost_wood_sensor_a1:on_activated()
	send_hero(lost_wood_sensor_a1, lost_wood_sensor_a2)
end

function lost_wood_sensor_b1:on_activated()
	send_hero(lost_wood_sensor_b1, lost_wood_sensor_b2)
end

function lost_wood_sensor_c1:on_activated()
	send_hero(lost_wood_sensor_c1, lost_wood_sensor_c2)
end

function lost_wood_sensor_d1:on_activated()
	send_hero(lost_wood_sensor_d1, lost_wood_sensor_d2)
end

function lost_wood_sensor_e1:on_activated()
	send_hero(lost_wood_sensor_e1, lost_wood_sensor_e2)
end