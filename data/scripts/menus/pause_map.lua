--Map Menu: Shows dungeon map overlay during dungeons/ overworld map in overworld.

local map_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local chest_loader = require("scripts/lib/chest_loader")

--Dimensions de l'Overworld
local world_map_width, world_map_height = 8000, 4800 --Taille Overworld
local world_map_left_margin, world_map_top_margin = 0, 0
local world_map_scale_x, world_map_scale_y = 8000 / 251, 4800 / 135 --A répéter ici
local dungeon_map_widget

function map_manager:new(game)

  local map_menu = {}

  local clouds_img = sol.surface.create("menus/clouds.png")
  local world_map_img
  local link_head_sprite = sol.sprite.create("menus/hero_head")
  local marker_farore_pearl = sol.sprite.create("menus/marker_farore_pearl")
  local marker_nayru_pearl = sol.sprite.create("menus/marker_nayru_pearl")
  local marker_din_pearl = sol.sprite.create("menus/marker_din_pearl")
  local marker_cross = sol.sprite.create("menus/marker_cross")
  local key_item_icon_img = sol.surface.create("menus/key_item_icon.png")
  local chest_icon_img = sol.surface.create("menus/chest_icon.png")
  local rooms_sprite
  local rooms_img
  local dungeon_map_widget
  local current_floor
  local selected_floor
  local num_floors
  local map
  local world
  local dungeon_index
  local dungeon
  local inventory_background = sol.surface.create("menus/map_background.png")

  -- Converts coordinates relative to the floor
  -- into coordinates relative to the dungeon minimap grid image.
  local function to_dungeon_minimap_coordinates(x, y)

    local scale_x, scale_y = 160 / 3200, 160 / 2400  -- The minimap is a grid of 10*10 rooms.
    x = x * scale_x
    y = y * scale_y
    return x, y
  end

  local function build_rooms_image()

    rooms_img = sol.surface.create(320, 168)
    rooms_sprite:set_animation(selected_floor)

    -- Background: show the whole floor as non visited.
    if game:has_dungeon_map() then
      rooms_sprite:set_direction(0)
      rooms_sprite:draw(rooms_img)
    end

    for i = 1, rooms_sprite:get_num_directions(floor_animation) - 1 do
      if game:has_explored_dungeon_room(dungeon_index, selected_floor, i) then
        -- If the room is visited, show it in another color.
        rooms_sprite:set_direction(i)
        rooms_sprite:draw(rooms_img)
      end
    end

    if game:has_dungeon_compass() then
      -- Key Item.
      local key_item = dungeon.key_item
      if key_item ~= nil
          and key_item.floor == selected_floor
          and key_item.savegame_variable ~= nil
          and not game:get_value(key_item.savegame_variable) then
        local dst_x, dst_y = to_dungeon_minimap_coordinates(key_item.x, key_item.y)
        dst_x, dst_y = dst_x - 4, dst_y - 4
        key_item_icon_img:draw(rooms_img, dst_x, dst_y)
      end

      -- Chests.
      if dungeon.chests == nil then
        -- Lazily load the chest information.
        dungeon.chests = chest_loader:load_chests(dungeon.maps)
      end
      for _, chest in ipairs(dungeon.chests) do
        if chest.floor == selected_floor
            and chest.savegame_variable ~= nil
            and not game:get_value(chest.savegame_variable) then
          -- Chests coordinates are already relative to their floor.
          local dst_x, dst_y = to_dungeon_minimap_coordinates(chest.x, chest.y)
          dst_x = dst_x - 13
          dst_y = dst_y - 1
          chest_icon_img:draw(rooms_img, dst_x, dst_y)
        end
      end
    end
  end

  local function build_dungeon_map_widget()
 
    dungeon_map_widget = gui_designer:create(320, 240)
    dungeon_map_widget:make_text(sol.language.get_string("menu_title.map"), 160, 13, "center")
    dungeon_map_widget:make_text(game:get_dungeon_name(), 159, 207, "center")

    -- Dungeon items.
    if game:has_dungeon_map() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("dungeons/map")
      dungeon_map_widget:make_sprite(sprite, 48, 180)
    end
    if game:has_dungeon_compass() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("dungeons/compass")
      dungeon_map_widget:make_sprite(sprite, 80, 180)
    end
    --if game:has_dungeon_stone_beak() then
    --  local sprite = sol.sprite.create("entities/items")
    --  sprite:set_animation("dungeons/stone_beak")
    --  dungeon_map_widget:make_sprite(sprite, 42, 224)
    --end
    --if game:has_dungeon_big_key() then
    --  local sprite = sol.sprite.create("entities/items")
    --  sprite:set_animation("dungeons/big_key")
    --  dungeon_map_widget:make_sprite(sprite, 42, 224)
    --end
    if game:has_dungeon_boss_key() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("dungeons/boss_key")
      dungeon_map_widget:make_sprite(sprite, 64, 148)
    end

    -- Floors.
    local lowest = dungeon.lowest_floor
    local highest = dungeon.highest_floor
    current_floor = game:get_map():get_floor()
    selected_floor = current_floor
    num_floors = highest - lowest + 1

    -- Rooms.
    rooms_sprite = sol.sprite.create(sol.language.get_language().."/dungeon_maps/map_" .. dungeon_index)
    build_rooms_image()
  end

  local function select_floor_up()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor + 1
    if selected_floor > dungeon.highest_floor then
      selected_floor = dungeon.lowest_floor
    end
    build_rooms_image()
  end

  local function select_floor_down()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor - 1
    if selected_floor < dungeon.lowest_floor then
      selected_floor = dungeon.highest_floor
    end
    build_rooms_image()
  end

  local function draw_dungeon_map(dst_surface)

    dungeon_map_widget:draw(dst_surface)

      -- Show rooms.
      rooms_img:draw(dst_surface, -32, 48)
    if game:has_dungeon_compass() then
      local map_x, map_y = map:get_location()
      local hero_x, hero_y = map:get_hero():get_position()
      dst_x, dst_y = to_dungeon_minimap_coordinates(map_x + hero_x, map_y + hero_y)
      dst_x, dst_y = dst_x + 128 - 20, dst_y + 48 - 6
      if selected_floor == current_floor then
        link_head_sprite:draw(dst_surface, dst_x, dst_y)
      end
    end
  end

  local function build_world_map_widget()
    -- World map.
    local map_x, map_y = map:get_location()
    local hero = map:get_hero()
    map_x, map_y = map_x + world_map_left_margin, map_y + world_map_top_margin
    -- Hero head
    local hero_x, hero_y = 0, 0
    if world == "outside_light" or world == "outside_dark"
    or world == "outside_light_labors_tott" then
      hero_x, hero_y = hero:get_position()
    end
    if world == "dungeon_10000" then
      hero_x, hero_y = 4000, 2400
    end
    local x, y = map_x + hero_x, map_y + hero_y
    x, y = x / world_map_scale_x, y / world_map_scale_y
    x, y = x - 8, y - 8
    link_head_sprite:set_xy(x + 36, y + 61)
    -- Farore Pearl
    local x, y = 0 + 160, 3840 + 101
    x, y = x / world_map_scale_x, y / world_map_scale_y
    x, y = x - 8, y - 8
    marker_farore_pearl:set_xy(x + 36, y + 61)
    -- Cross: Zelda
    local x, y = 3200 + 800, 1920 + 173
    x, y = x / world_map_scale_x, y / world_map_scale_y
    x, y = x - 8, y - 8
    marker_cross:set_xy(x + 40, y + 67)
    -- Nayru Pearl
    local x, y = 960 + 160, 1920 + 509
    x, y = x / world_map_scale_x, y / world_map_scale_y
    x, y = x - 8, y - 8
    marker_nayru_pearl:set_xy(x + 32, y + 61)
    -- Din Pearl
    local x, y = 6400 + 800, 0 + 117
    x, y = x / world_map_scale_x, y / world_map_scale_y
    x, y = x - 8, y - 8
    marker_din_pearl:set_xy(x + 36, y + 61)
  end

  local function draw_world_map(dst_surface)
    world_map_widget = gui_designer:create(320, 240)
    world_map_widget:make_text(sol.language.get_string("menu_title.map"), 160, 13, "center")

    --LIGHT WORLD
    if world == "outside_light" or world == "outside_light_2" 
      or world == "inside_world" 
      or world == "dungeon_16"
      or world == "dungeon_17"
      or world == "dungeon_100" then
      world_map_widget:make_text(sol.language.get_string("light_world_caption"), 159, 207, "center")
	    world_map_img:draw(dst_surface)

  	  --Nuages pour les zones non explorées
      if not game:get_value("light_A1_explored") then clouds_img:draw(dst_surface,36,61) end
      if not game:get_value("light_A2_explored") then clouds_img:draw(dst_surface,36,88) end
      if not game:get_value("light_A3_explored") then clouds_img:draw(dst_surface,36,115) end
      if not game:get_value("light_A4_explored") then clouds_img:draw(dst_surface,36,142) end
      if not game:get_value("light_A5_explored") then clouds_img:draw(dst_surface,36,169) end
      if not game:get_value("light_B1_explored") then clouds_img:draw(dst_surface,86,61) end
      if not game:get_value("light_B2_explored") then clouds_img:draw(dst_surface,86,88) end
      if not game:get_value("light_B3_explored") then clouds_img:draw(dst_surface,86,115) end
      if not game:get_value("light_B4_explored") then clouds_img:draw(dst_surface,86,142) end
      if not game:get_value("light_B5_explored") then clouds_img:draw(dst_surface,86,169) end
      if not game:get_value("light_C1_explored") then clouds_img:draw(dst_surface,136,61) end
      if not game:get_value("light_C2_explored") then clouds_img:draw(dst_surface,136,88) end
      if not game:get_value("light_C3_explored") then clouds_img:draw(dst_surface,136,115) end
      if not game:get_value("light_C4_explored") then clouds_img:draw(dst_surface,136,142) end
      if not game:get_value("light_C5_explored") then clouds_img:draw(dst_surface,136,169) end
      if not game:get_value("light_D1_explored") then clouds_img:draw(dst_surface,186,61) end
      if not game:get_value("light_D2_explored") then clouds_img:draw(dst_surface,186,88) end
      if not game:get_value("light_D3_explored") then clouds_img:draw(dst_surface,186,115) end
      if not game:get_value("light_D4_explored") then clouds_img:draw(dst_surface,186,142) end
      if not game:get_value("light_D5_explored") then clouds_img:draw(dst_surface,186,169) end
      if not game:get_value("light_E1_explored") then clouds_img:draw(dst_surface,236,61) end
      if not game:get_value("light_E2_explored") then clouds_img:draw(dst_surface,236,88) end
      if not game:get_value("light_E3_explored") then clouds_img:draw(dst_surface,236,115) end
      if not game:get_value("light_E4_explored") then clouds_img:draw(dst_surface,236,142) end
      if not game:get_value("light_E5_explored") then clouds_img:draw(dst_surface,236,169) end

    --DARK WORLD
    elseif world == "outside_dark" or world == "outside_dark_2" or world == "inside_world_dark" then
      world_map_widget:make_text(sol.language.get_string("dark_world_caption"), 159, 207, "center")
      world_map_img:draw(dst_surface)

  	  --Nuages pour les zones non explorées
      if not game:get_value("dark_A1_explored") then clouds_img:draw(dst_surface,36,61) end
      if not game:get_value("dark_A2_explored") then clouds_img:draw(dst_surface,36,88) end
      if not game:get_value("dark_A3_explored") then clouds_img:draw(dst_surface,36,115) end
      if not game:get_value("dark_A4_explored") then clouds_img:draw(dst_surface,36,142) end
      if not game:get_value("dark_A5_explored") then clouds_img:draw(dst_surface,36,169) end
      if not game:get_value("dark_B1_explored") then clouds_img:draw(dst_surface,86,61) end
      if not game:get_value("dark_B2_explored") then clouds_img:draw(dst_surface,86,88) end
      if not game:get_value("dark_B3_explored") then clouds_img:draw(dst_surface,86,115) end
      if not game:get_value("dark_B4_explored") then clouds_img:draw(dst_surface,86,142) end
      if not game:get_value("dark_B5_explored") then clouds_img:draw(dst_surface,86,169) end
      if not game:get_value("dark_C1_explored") then clouds_img:draw(dst_surface,136,61) end
      if not game:get_value("dark_C2_explored") then clouds_img:draw(dst_surface,136,88) end
      if not game:get_value("dark_C3_explored") then clouds_img:draw(dst_surface,136,115) end
      if not game:get_value("dark_C4_explored") then clouds_img:draw(dst_surface,136,142) end
      if not game:get_value("dark_C5_explored") then clouds_img:draw(dst_surface,136,169) end
      if not game:get_value("dark_D1_explored") then clouds_img:draw(dst_surface,186,61) end
      if not game:get_value("dark_D2_explored") then clouds_img:draw(dst_surface,186,88) end
      if not game:get_value("dark_D3_explored") then clouds_img:draw(dst_surface,186,115) end
      if not game:get_value("dark_D4_explored") then clouds_img:draw(dst_surface,186,142) end
      if not game:get_value("dark_D5_explored") then clouds_img:draw(dst_surface,186,169) end
      if not game:get_value("dark_E1_explored") then clouds_img:draw(dst_surface,236,61) end
      if not game:get_value("dark_E2_explored") then clouds_img:draw(dst_surface,236,88) end
      if not game:get_value("dark_E3_explored") then clouds_img:draw(dst_surface,236,115) end
      if not game:get_value("dark_E4_explored") then clouds_img:draw(dst_surface,236,142) end
      if not game:get_value("dark_E5_explored") then clouds_img:draw(dst_surface,236,169) end

    --Travaux de Zeldo - Manoir
    elseif world == "dungeon_10000" then
      world_map_widget:make_text(sol.language.get_string("labors_castle_caption"), 159, 207, "center")
      world_map_img:draw(dst_surface)

    --Travaux de Zeldo - TotT
    elseif world == "outside_light_labors_tott" or world == "inside_world_labors_tott" then
      world_map_widget:make_text(sol.language.get_string("light_world_caption"), 159, 207, "center")
      world_map_img:draw(dst_surface)

    end
    world_map_widget:draw(dst_surface)

  end

  function map_menu:on_started()

    link_head_sprite:set_animation("tunic" .. game:get_ability("tunic"))

    map = game:get_map()
    world = map:get_world()
    dungeon_index = game:get_dungeon_index()
    dungeon = game:get_dungeon()
    rooms_img = nil
    if world == "outside_light" or world == "outside_light_2" 
      or world == "inside_world" 
      or world == "dungeon_16"
      or world == "dungeon_17"
      or world == "dungeon_100" then
      world_map_img = sol.surface.create("menus/world_map.png") 
    elseif world == "outside_dark" or world == "outside_dark_2" or world == "inside_world_dark" then
      world_map_img = sol.surface.create("menus/world_map_dark.png")

    --Travaux de Zeldo - Manoir
    elseif world == "dungeon_10000" then
      world_map_img = sol.surface.create("menus/world_map_labors_castle.png")

    --Travaux de Zeldo - TotT
    elseif world == "outside_light_labors_tott" or world == "inside_world_labors_tott" then
      world_map_img = sol.surface.create("menus/world_map_labors_tott.png")

    end
    if dungeon == nil then
      build_world_map_widget()
    else
      build_dungeon_map_widget()
    end
  end

  function map_menu:on_draw(dst_surface)

    if dungeon == nil then
      inventory_background:draw(dst_surface) 
      draw_world_map(dst_surface)
      link_head_sprite:draw(dst_surface)
      if game:get_value("get_sword_1") and not game:get_value("get_farore_pearl")then marker_farore_pearl:draw(dst_surface) end
      if game:get_value("can_leave_forest") and not game:get_value("zelda_1st_time")then marker_cross:draw(dst_surface) end
      if game:get_value("zelda_1st_time") and not game:get_value("get_nayru_pearl")then marker_nayru_pearl:draw(dst_surface) end
      if game:get_value("get_nayru_pearl") and not game:get_value("get_din_pearl_1")then marker_din_pearl:draw(dst_surface) end
    else
      inventory_background:draw(dst_surface)
      draw_dungeon_map(dst_surface)
    end
  end

  function map_menu:on_command_pressed(command)

    local handled = false
    if dungeon ~= nil then
      if command == "up" then
        if game:has_dungeon_map() then select_floor_up() end
        handled = true
      elseif command == "down" then
        if game:has_dungeon_map() then select_floor_down() end
        handled = true
      end
    end

    return handled
  end

  return map_menu
end

return map_manager