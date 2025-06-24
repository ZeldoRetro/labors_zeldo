local map = ...
local game = map:get_game()

local light_img = sol.surface.create(320,240)
light_img:fill_color({255, 255, 255})
local light = false

map:register_event("on_draw",function(map,dst_surface)
  if light then light_img:draw(dst_surface) end
end)

-- DEBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  --Plus nécessaire de devoir revaincre les monstres si les portes sont ouvertes
  if game:get_value("door_10018_1") then
    auto_enemy_auto_door_1_1:remove()
    auto_enemy_auto_door_1_2:remove()
  end
  if game:get_value("door_10018_2") then
    auto_enemy_auto_door_2_1:remove()
    auto_enemy_auto_door_2_2:remove()
  end
  if game:get_value("door_10018_3") then
    auto_enemy_auto_door_3_1:remove()
    auto_enemy_auto_door_3_2:remove()
  end

  -- Musique de la Tour de Ganon quand on arrive à l'entrée
  if destination == start then sol.audio.play_music("creations/labors/1st_solarus_quest/ganon_tower") end

  -- Pad Triangles
  local function flashing(entity)
    entity:get_sprite():fade_out(50,function()
      entity:get_sprite():fade_in(50,function()
        flashing(entity)
      end)
    end)
  end
  
  if triangle_pad_courage ~= nil then
    flashing(triangle_pad_courage)
  end
  if triangle_pad_wisdom ~= nil then
    flashing(triangle_pad_wisdom)
  end
  if triangle_pad_force ~= nil then
    flashing(triangle_pad_force)
  end

  -- Cutscene Triforce disponible
  if not game:get_value("triforce_tp_opened_10018") then
    if game:get_value("get_pendant_10011") and game:get_value("get_pendant_10012") and game:get_value("get_pendant_10013") then
      triforce_switch:set_enabled(true)
    end
  else
    map:get_entity("ts.labors.1st_solarus_quest.triforce_shrine_hint"):set_enabled(false)
    map:get_entity("ts.labors.1st_solarus_quest.triforce_shrine_hint_wall"):set_enabled(false)
  end

  --Modèle LINK
  hero:set_tunic_sprite_id("hero/tunic3")
  hero:set_sword_sprite_id("hero/sword4")
  if game:get_value("get_shield_10018") then hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield3")
  else hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield2") end
end)

-- TRIGGER EVENTS
map:register_event("on_opening_transition_finished",function(map, destination)
  if destination == dest_event_o then
    hero:freeze()
    sol.timer.start(map, 500, function()
      map:open_doors("auto_door_9")
      sol.timer.start(map, 700, function()
        sol.audio.play_sound("secret")
        hero:teleport(dest_event_o:get_property("tp_map"), dest_event_o:get_property("dest"))
      end)
    end)
  end
  if destination == dest_event_e then
    hero:freeze()
    sol.timer.start(map, 500, function()
      map:open_doors("auto_door_a")
      sol.timer.start(map, 700, function()
        sol.audio.play_sound("secret")
        hero:teleport(dest_event_e:get_property("tp_map"), dest_event_e:get_property("dest"))
      end)
    end)
  end
end)

-- SWITCH INVISIBLE ACTIVE COFFRE DU CRISTAL DE SOUVENIR
function invisible_path_switch:on_activated()
  auto_switch_auto_chest:on_activated()
end

-- CUTSCENE TP TRIFORCE
function triforce_switch:on_activated()
  sol.audio.play_music("none")
  hero:freeze()
  game:set_pause_allowed(false)
  pendant_1:set_enabled(true)
  pendant_2:set_enabled(true)
  pendant_3:set_enabled(true)
  local m1 = sol.movement.create("target")
  m1:set_speed(16)
  m1:set_target(target_pendant_1)
  m1:start(pendant_1)
  local m2 = sol.movement.create("target")
  m2:set_speed(16)
  m2:set_target(target_pendant_2)
  m2:start(pendant_2)
  local m3 = sol.movement.create("target")
  m3:set_speed(16)
  m3:set_target(target_pendant_3)
  m3:start(pendant_3,function()
    pendant_1:get_sprite():set_animation("flashing")
    pendant_2:get_sprite():set_animation("flashing")
    pendant_3:get_sprite():set_animation("flashing")
    sol.audio.play_sound("laser")
      light = true
      light_img:fade_in(10,function()
        pendant_1:set_enabled(false)
        pendant_2:set_enabled(false)
        pendant_3:set_enabled(false)
        map:get_entity("ts.labors.1st_solarus_quest.triforce_shrine_hint"):set_enabled(false)
        map:get_entity("ts.labors.1st_solarus_quest.triforce_shrine_hint_wall"):set_enabled(false)
        telep_triforce_room:set_enabled(true)
        light_img:fade_out(100,function()
          sol.audio.play_sound("secret")
          game:set_pause_allowed(true)
          game:set_value("triforce_tp_opened_10018", true)
          hero:unfreeze()
        end)
      end)
  end)
end

-- COMBAT FINAL
function sensor_final_boss:on_activated()
  self:set_enabled(false)
  hero:freeze()
  sol.audio.play_music("none")
  map:close_doors("final_boss_door")
  sol.timer.start(map, 1000, function()
    game:set_dialog_position("bottom")
    game:start_dialog("LABORS.1st_solarus_quest.ganon",function()
      game:set_dialog_position("auto")
      ganon_npc:set_enabled(false)
      boss:set_enabled(true)
      throne_room_decoration:get_sprite():fade_out(20)
      sol.audio.play_music("razer_boss")
      hero:unfreeze()
    end)
  end)
end

-- BOSS GANON
if boss ~= nil then
  function boss:on_dying()
    hero:freeze()
    sol.audio.play_music("none")
  end
  function boss:on_dead()
      game:set_value("labors_wave_2_1_done",true)
      hero:freeze()
      game:set_pause_allowed(false)
      game:set_life(game:get_max_life())
      game:set_magic(game:get_max_magic())
      sol.audio.play_music("victory")
      sol.timer.start(8000,function() 
        hero:start_victory()
        sol.timer.start(1000,function()
          game:set_pause_allowed(true)
          hero:teleport("creations/labors/1st_solarus_quest/hub","start_final","fade")
        end)     
      end)  
  end
end