--Inventory Menu: Assignables items and equipment items. This submenu shows the loots

local inventory_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local item_names = {
  -- Place inventory items here
  "inventory/ocarina",  
  "inventory/boomerang",
  "inventory/bow",
  "inventory/fire_rod",
  "treasures/spoils_bag",
  "inventory/clock",
  "inventory/clock",
  "inventory/clock",
  "inventory/bombs_counter", 
  "inventory/hookshot", 
  "inventory/hammer",
  "inventory/ice_rod", 
  "inventory/clock", 
  "inventory/clock", 
  "inventory/clock",
  "inventory/clock",
  "inventory/clock",
  "inventory/monicle_truth",
  "inventory/lamp",
  "inventory/bow_light",
  "inventory/clock",
  "inventory/clock",
  "inventory/clock",
  "inventory/clock",
  "inventory/bottle_1",
  "inventory/bottle_2",
  "inventory/bottle_3",
  "inventory/bottle_4",
  "inventory/clock",
  "inventory/clock",
  "inventory/magic_cape",
  "inventory/echange",
}
local items_num_columns = 8
local items_num_rows = math.ceil(#item_names / items_num_columns)
local piece_of_heart_icon_img = sol.surface.create("hud/piece_of_heart_icon.png")
local icons_img = sol.surface.create("menus/stats_icons.png")
local items_img = sol.surface.create("entities/items.png")
local inventory_background = sol.surface.create("menus/inventory_treasures_background.png")
local movement_speed = 800
local movement_distance = 1

local song_names = {
  -- Place inventory items here
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_green",
  "treasures/loot_chuchu_blue",
  "treasures/loot_joy_pendant",
  "treasures/loot_monster_claw",
  "treasures/loot_stalfos_skull",
  "treasures/loot_stalfos_skull_gold",
  "treasures/loot_knight_crest",
  "treasures/loot_lucky_egg",
}
local songs_num_columns = 3
local items_num_rows = math.ceil(#song_names / songs_num_columns)

local item_caption

--FENETRE DES OBJETS D'INVENTAIRE
local function create_item_widget(game)
  local widget = gui_designer:create(320, 240)
  widget:set_xy(17 - movement_distance, 55)
  local items_surface = widget:get_surface()

  for i, item_name in ipairs(item_names) do
    local variant = game:get_item(item_name):get_variant()
    if variant > 0 then
      local column = (i - 1) % items_num_columns + 1
      local row = math.floor((i - 1) / items_num_columns + 1)
      -- Draw the sprite statically. This is okay as long as
      -- item sprites are not animated.
      -- If they become animated one day, they will have to be
      -- drawn at each frame instead (in on_draw()).
      local item_sprite = sol.sprite.create("entities/items")
      item_sprite:set_animation(item_name)
      item_sprite:set_direction(variant - 1)
      item_sprite:set_xy(16 + column * 32 - 16, 13 + row * 32 - 16)
      item_sprite:draw(items_surface)
      if game:get_item(item_name):has_amount() then
        -- Show a counter in this case.
        local amount = game:get_item(item_name):get_amount()
        if game:get_item(item_name):get_amount() == game:get_item(item_name):get_max_amount() then
          widget:make_green_counter(amount, 16 + column * 32 - 16, 13 + row * 32 - 20)
        else
          widget:make_counter(amount, 16 + column * 32 - 16, 13 + row * 32 - 20)
        end
      end
    end
  end
  return widget
end

--FENETRE DES CHANTS
local function create_song_widget(game)
  local widget = gui_designer:create(320, 240)
  widget:set_xy(177 - movement_distance, 55)
  local items_surface = widget:get_surface()


  for i, song_name in ipairs(song_names) do
    local variant = game:get_item(song_name):get_variant()
    if variant > 0 then
      local column = (i - 1) % songs_num_columns + 1
      local row = math.floor((i - 1) / songs_num_columns + 1)
      -- Draw the sprite statically. This is okay as long as
      -- item sprites are not animated.
      -- If they become animated one day, they will have to be
      -- drawn at each frame instead (in on_draw()).
      local item_sprite = sol.sprite.create("entities/items")
      item_sprite:set_animation(song_name)
      item_sprite:set_direction(variant - 1)
      item_sprite:set_xy(16 + column * 32 - 16, 13 + row * 32 - 16)
      item_sprite:draw(items_surface)
      if game:get_item(song_name):has_amount() then
        -- Show a counter in this case.
        local amount = game:get_item(song_name):get_amount()
        if game:get_item(song_name):get_amount() == game:get_item(song_name):get_max_amount() then
          widget:make_green_counter(amount, 16 + column * 32 - 16, 13 + row * 32 - 20)
        else
          widget:make_counter(amount, 16 + column * 32 - 16, 13 + row * 32 - 20)
        end
      end
    end
  end
  return widget
end

--TITRE DU MENU
local function create_menu_title_widget(game)
  local widget = gui_designer:create(72, 28)
  widget:set_xy(124, 29)
  widget:make_text(sol.language.get_string("menu_title.inventory"), 6, 6, "left")
  return widget
end

function inventory_manager:new(game)

  local inventory = {}

  local state = "opening"  -- "opening", "ready" or "closing".

  local item_widget = create_item_widget(game)
  local menu_title_widget = create_menu_title_widget(game)

  local song_widget = create_song_widget(game)
  
  local item_cursor_moving_sprite = sol.sprite.create("menus/item_cursor")
  item_cursor_moving_sprite:set_animation("solid_fixed")

  -- Determine the place of the item currently assigned if any.
  local item_assigned_row, item_assigned_column, item_assigned_index
  local item_assigned = game:get_item_assigned(1)
  if item_assigned ~= nil then
    local item_name_assigned = item_assigned:get_name()
    for i, item_name in ipairs(item_names) do

      if item_name == item_name_assigned then
        item_assigned_column = (i - 1) % items_num_columns
        item_assigned_row = math.floor((i - 1) / songs_num_columns)
        item_assigned_index = i - 1
      end
    end
  end

  -- Draws the inventory item name
  local item_caption_text = sol.text_surface.create{
    font = "dialog",
    horizontal_alignment = "center",
    vertical_alignment = "top",
  }
  local function draw_item_name(dst_surface)
    item_caption_text:set_text(item_caption)
    item_caption_text:draw(dst_surface, 159, 207)
  end

  local cursor_index = 0
  local cursor_row = math.floor(cursor_index / songs_num_columns)
  local cursor_column = cursor_index % songs_num_columns

  -- Draws cursors on the selected and on the assigned items.
  local function draw_item_cursors(dst_surface)

    -- Selected item.
    local widget_x, widget_y = song_widget:get_xy()
    item_cursor_moving_sprite:draw(
        dst_surface,
        widget_x + 32 + 32 * cursor_column,
        widget_y + 24 + 32 * cursor_row
    )
  end

  -- Changes the position of the item cursor.
  local function set_cursor_position(row, column)
    cursor_row = row
    cursor_column = column
    cursor_index = cursor_row * songs_num_columns + cursor_column
    if cursor_index == item_assigned_index then
      item_cursor_moving_sprite:set_animation("solid_fixed")
    end

    local song_name = song_names[cursor_index + 1]
    local item = song_name and song_name ~= "" and game:get_item(song_name) or nil
    local variant = item and item:get_variant() or 0

    if variant > 0 then
      item_caption = sol.language.get_string("inventory.item_caption." .. song_name .. "." .. variant)
      --game:set_custom_command_effect("action", "info")
    else
      item_caption = nil
      --game:set_custom_command_effect("action", nil)
    end
  end

  function inventory:on_draw(dst_surface)

    inventory_background:draw(dst_surface)

    item_widget:draw(dst_surface)
    menu_title_widget:draw(dst_surface)
    song_widget:draw(dst_surface)

    -- Show the item cursors and name
    draw_item_cursors(dst_surface)
    draw_item_name(dst_surface)
  end

  function inventory:on_command_pressed(command)

    if state ~= "ready" then
      return true
    end

    local handled = false

    if command == "pause" then
      -- Close the pause menu.
      state = "closing"
      sol.audio.play_sound("pause_closed")
      game:set_paused(false)
      handled = true

    elseif command == "item_1" then
      -- Assign an item.
      local item = game:get_item(song_names[cursor_index + 1])
      if item == game:get_item_assigned(2) then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(2, game:get_item_assigned(1))
        game:set_item_assigned(1, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      elseif cursor_index ~= item_assigned_index
          and item:has_variant()
          and item:is_assignable() then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(1, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      end
      handled = true

    elseif command == "item_2" then
      -- Assign an item.
      local item = game:get_item(song_names[cursor_index + 1])
      if item == game:get_item_assigned(1) then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(1, game:get_item_assigned(2))
        game:set_item_assigned(2, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      elseif cursor_index ~= item_assigned_index
          and item:has_variant()
          and item:is_assignable() then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(2, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      end
      handled = true

    elseif command == "right" then
      if cursor_column < songs_num_columns - 1 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column + 1)
        handled = true
      else return end
    elseif command == "left" then
      if cursor_column > 0 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column - 1)
        handled = true
      else return end
    elseif command == "up" then
      sol.audio.play_sound("cursor")
      if cursor_row > 0 then
        set_cursor_position(cursor_row - 1, cursor_column)
      else
        set_cursor_position(items_num_rows - 1, cursor_column)
      end
      handled = true
    elseif command == "down" then
      sol.audio.play_sound("cursor")
      if cursor_row < items_num_rows - 1 then
        set_cursor_position(cursor_row + 1, cursor_column)
      else
        set_cursor_position(0, cursor_column)
      end
      handled = true
    end

    return handled
  end

  set_cursor_position(cursor_row, cursor_column)
  state = "ready"

  return inventory
end

return inventory_manager