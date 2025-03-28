local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  --Equipement requis pour le Temple + Initialisation variables
  if destination == escalier_nord then

    --Modèle LINK
    hero:set_tunic_sprite_id("hero/tunic3")

    game:set_max_life(14*4)
    game:set_life(game:get_max_life())
    game:set_item_assigned(1, nil)
    game:set_item_assigned(2, nil)
    game:get_item("equipment/tunic"):set_variant(3)
    game:set_ability("tunic",3)
    game:get_item("equipment/sword"):set_variant(3)
    game:get_item("equipment/shield"):set_variant(3)

    game:set_value("force",4)
    game:set_value("defense",4)

    game:get_item("inventory/lamp"):set_variant(1)
    game:get_item("inventory/boomerang"):set_variant(1)
    game:get_item("inventory/hookshot"):set_variant(1)
    game:get_item("inventory/hammer"):set_variant(1)
    game:get_item("inventory/fire_rod"):set_variant(1)
    game:get_item("inventory/ice_rod"):set_variant(1)
    game:get_item("inventory/monicle_truth"):set_variant(1)
    game:get_item("equipment/bomb_bag"):set_variant(1)
    local bombs_counter = game:get_item("inventory/bombs_counter")
    bombs_counter:set_variant(1)
    bombs_counter:set_amount(20)
    game:get_item("equipment/quiver"):set_variant(1)
    local arrows_counter = game:get_item("inventory/bow")
    arrows_counter:set_variant(1)
    arrows_counter:set_amount(30)

    --Upgrades si achat au magasin
    if game:get_value("tott_upgrade_card_force_active") then local force = game:get_value("force") game:set_value("force", force + 1) end
    if game:get_value("tott_upgrade_card_defense_active") then local defense = game:get_value("defense") game:set_value("defense", defense + 1) end
    if game:get_value("tott_upgrade_card_arrows_active") then game:get_item("equipment/quiver"):set_variant(2) game:get_item("inventory/bow"):set_amount(50) end
    if game:get_value("tott_upgrade_card_bombs_active") then game:get_item("equipment/bomb_bag"):set_variant(2) game:get_item("inventory/bombs_counter"):set_amount(40) end

  end

  --Barrières électriques
  if game:get_value("dungeon_10007_barrier_1_opened") then electric_barrier_1_sensor:set_enabled(false) end
  if game:get_value("dungeon_10007_barrier_2_opened") then electric_barrier_2_sensor:set_enabled(false) end
  if game:get_value("dungeon_10007_barrier_3_opened") then electric_barrier_3_sensor:set_enabled(false) end

end)

--BARRIÈRES ÉLECTRIQUES
function electric_barrier_1_sensor:on_activated()
  sol.audio.play_sound("door_closed")
  map:set_entities_enabled("electric_barrier_1_",true)
  self:set_enabled(false)
end
function electric_barrier_2_sensor:on_activated()
  sol.audio.play_sound("door_closed")
  map:set_entities_enabled("electric_barrier_2_",true)
  self:set_enabled(false)
end
function electric_barrier_3_sensor:on_activated()
  sol.audio.play_sound("door_closed")
  map:set_entities_enabled("electric_barrier_3",true)
  self:set_enabled(false)
end

for enemy in map:get_entities("electric_barrier_1_enemy_") do
  function enemy:on_dead()
    if not map:has_entities("electric_barrier_1_enemy_") then
      sol.audio.play_sound("correct")
      sol.audio.play_sound("door_open")
      map:set_entities_enabled("electric_barrier_1_",false)
      game:set_value("dungeon_10007_barrier_1_opened",true)
    end
  end
end
for enemy in map:get_entities("electric_barrier_2_enemy_") do
  function enemy:on_dead()
    if not map:has_entities("electric_barrier_2_enemy_") then
      sol.audio.play_sound("correct")
      sol.audio.play_sound("door_open")
      map:set_entities_enabled("electric_barrier_2_",false)
      game:set_value("dungeon_10007_barrier_2_opened",true)
    end
  end
end
for enemy in map:get_entities("electric_barrier_3_enemy_") do
  function enemy:on_dead()
    if not map:has_entities("electric_barrier_3_enemy_") then
      sol.audio.play_sound("correct")
      sol.audio.play_sound("door_open")
      map:set_entities_enabled("electric_barrier_3",false)
      game:set_value("dungeon_10007_barrier_3_opened",true)
    end
  end
end