local map = ...
local game = map:get_game()
local music_map = map:get_music()

-- DÉBUT DE LA MAP
map:register_event("on_started",function(map, destination)

  -- Initialisation bassins et switches
  for switch in map:get_entities("bath_1_switch_") do switch:set_activated(true) end

  --Modèle LINK
  hero:set_tunic_sprite_id("hero/tunic1")
  hero:set_sword_sprite_id("hero/sword1")
  hero:set_shield_sprite_id("npc/playing_character/link_1st_solarus_quest/shield1")

end)

-- SWITCHES ET SYSTÈME DE BASSINS

for switch in map:get_entities("bath_2_switch_") do
  function switch:on_activated()
    hero:freeze()
    for switch in map:get_entities("bath_2_switch_") do switch:set_activated(true) end
    sol.audio.play_sound("water_drain")
    sol.timer.start(map, 1000, function()
      map:set_entities_enabled("bath_1_step_3_", false)
      map:set_entities_enabled("bath_2_step_1_", true)
      sol.timer.start(map, 1000, function()
        map:set_entities_enabled("bath_1_step_2_", false)
        map:set_entities_enabled("bath_2_step_2_", true)
        sol.timer.start(map, 1000, function()
          map:set_entities_enabled("bath_1_step_1_", false)
          map:set_entities_enabled("bath_2_step_3_", true)
          for switch in map:get_entities("bath_1_switch_") do switch:set_activated(false) end
          hero:unfreeze()
          sol.audio.play_sound("secret")
        end)
      end)
    end)
  end
end

for switch in map:get_entities("bath_1_switch_") do
  function switch:on_activated()
    hero:freeze()
    for switch in map:get_entities("bath_1_switch_") do switch:set_activated(true) end
    sol.audio.play_sound("water_drain")
    sol.timer.start(map, 1000, function()
      map:set_entities_enabled("bath_2_step_3_", false)
      map:set_entities_enabled("bath_1_step_1_", true)
      sol.timer.start(map, 1000, function()
        map:set_entities_enabled("bath_2_step_2_", false)
        map:set_entities_enabled("bath_1_step_2_", true)
        sol.timer.start(map, 1000, function()
          map:set_entities_enabled("bath_2_step_1_", false)
          map:set_entities_enabled("bath_1_step_3_", true)
          for switch in map:get_entities("bath_2_switch_") do switch:set_activated(false) end
          hero:unfreeze()
          sol.audio.play_sound("secret")
        end)
      end)
    end)
  end
end

--ENIGME DE BLOCS 1

local block_puzzle_1_switches = 0
local goal_block_puzzle_1 = 4
for switch in map:get_entities("block_puzzle_1_switch") do
  function switch:on_activated()
    block_puzzle_1_switches = block_puzzle_1_switches + 1
    if block_puzzle_1_switches == goal_block_puzzle_1 then
      sol.timer.start(map, 100, function()
        auto_switch_auto_chest_key_1:set_enabled(true)
        block_puzzle_1_fake_switch:set_enabled(false)
        local i = 0
        while i < goal_block_puzzle_1 do
          i = i + 1
          map:get_entity("definitive_block_puzzle_1_block_"..i):set_enabled(true)
          map:get_entity("block_puzzle_1_block_"..i):set_enabled(false)
        end
      end)
    end
  end
  function switch:on_inactivated()
    block_puzzle_1_switches = block_puzzle_1_switches - 1
  end
end

--ENIGME DE BLOCS 2

local block_puzzle_2_switches = 0
local goal_block_puzzle_2 = 2
for switch in map:get_entities("block_puzzle_2_switch") do
  function switch:on_activated()
    block_puzzle_2_switches = block_puzzle_2_switches + 1
    if block_puzzle_2_switches == goal_block_puzzle_2 then
      sol.timer.start(map, 100, function()
        auto_switch_auto_door_3:set_enabled(true)
        block_puzzle_2_fake_switch:set_enabled(false)
        local i = 0
        while i < goal_block_puzzle_2 do
          i = i + 1
          map:get_entity("definitive_block_puzzle_2_block_"..i):set_enabled(true)
          map:get_entity("block_puzzle_2_block_"..i):set_enabled(false)
        end
      end)
    end
  end
  function switch:on_inactivated()
    block_puzzle_2_switches = block_puzzle_2_switches - 1
  end
end

--ENIGME DE BLOCS 3

local block_puzzle_3_switches = 0
local goal_block_puzzle_3 = 2
for switch in map:get_entities("block_puzzle_3_switch") do
  function switch:on_activated()
    block_puzzle_3_switches = block_puzzle_3_switches + 1
    if block_puzzle_3_switches == goal_block_puzzle_3 then
      sol.timer.start(map, 100, function()
        auto_switch_auto_door_1:set_enabled(true)
        block_puzzle_3_fake_switch:set_enabled(false)
        local i = 0
        while i < goal_block_puzzle_3 do
          i = i + 1
          map:get_entity("definitive_block_puzzle_3_block_"..i):set_enabled(true)
          map:get_entity("block_puzzle_3_block_"..i):set_enabled(false)
        end
      end)
    end
  end
  function switch:on_inactivated()
    block_puzzle_3_switches = block_puzzle_3_switches - 1
  end
end