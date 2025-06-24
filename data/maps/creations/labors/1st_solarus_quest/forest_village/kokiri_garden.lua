local map = ...
local game = map:get_game()

--Enemis et entités invisibles
for entity in map:get_entities("invisible_path") do
	entity:set_visible(false)
end