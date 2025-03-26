--Quest Status Menu

local quest_status_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local item_names = {
  -- Place inventory items here
  "upgrade_cards/tott_casual",
  "upgrade_cards/tott_arrows",
  "upgrade_cards/tott_bombs",
  "upgrade_cards/tott_defence",
  "upgrade_cards/tott_attack",
  "upgrade_cards/tott_magic",
}
local items_num_columns = 3
local items_num_rows = math.ceil(#item_names / items_num_columns)
local piece_of_heart_icon_img = sol.surface.create("hud/piece_of_heart_icon.png")
local icons_img = sol.surface.create("menus/stats_icons.png")
local items_img = sol.surface.create("entities/items.png")
local quest_status_background = sol.surface.create("menus/quest_status_background.png")
local movement_speed = 800
local movement_distance = 1

local item_caption

--FENETRE DES OBJETS D'INVENTAIRE
local function create_equipment_items_widget(game)
  local widget = gui_designer:create(320, 240)
  widget:set_xy(17 - movement_distance, 119)
  local items_surface = widget:get_surface()

  local item_sprites = {}

  local temp = 0

  for i, item_name in ipairs(item_names) do
    local variant = game:get_item(item_name):get_variant()
    if variant > 0 then
      local column = (i - 1) % items_num_columns + 1
      local row = math.floor((i - 1) / items_num_columns + 1)
      local item_sprite = sol.sprite.create("entities/items")

      item_sprites[temp] = sol.sprite.create("entities/items")
      item_sprites[temp]:set_animation(item_name)
      item_sprites[temp]:set_direction(variant - 1)
      item_sprites[temp]:set_xy(16 + column * 32 - 16, 13 + row * 32 - 16)
      item_sprites[temp]:draw(items_surface)
      temp = temp + 1

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
  return widget, item_sprites
end

--TITRE DU MENU
local function create_menu_title_widget(game)
  local widget = gui_designer:create(80, 28)
  widget:set_xy(118, 7)
  widget:make_text(sol.language.get_string("menu_title.quest_status"), 6, 6, "left")
  return widget
end

--QUARTS DE COEUR
local function create_pieces_of_heart_widget(game)
  local widget = gui_designer:create(320, 240)
  widget:set_xy(135, 70)
  local pieces_of_heart_img = sol.surface.create("menus/quest_status_pieces_of_heart.png")
  local num_pieces_of_heart = game:get_item("quest_items/piece_of_heart"):get_num_pieces_of_heart()
  local x = 51 * num_pieces_of_heart
  pieces_of_heart_img:draw_region(x, 0, 51, 50, widget:get_surface(), 0, 0)
  return widget
end

--FENETRE DU STATUT QUETE
local function create_status_widget(game)
  local widget = gui_designer:create(192, 196)

  widget:set_xy(196, 60)

  --Objets quête principale (1)
  local colonne_p = 0
  local rangee_p = 107
  if game:get_value("yellow_key_10000_1") then widget:make_image_region(items_img, 448, 16, 16, 16, colonne_p, rangee_p) end
  if game:get_value("red_key_10000_1_1") then widget:make_image_region(items_img, 480, 0, 16, 16, colonne_p + 24, rangee_p) end
  if game:get_value("blue_key_10000_1_1") then widget:make_image_region(items_img, 464, 16, 16, 16, colonne_p + 48, rangee_p) end
  if game:get_value("green_key_10000_1_1") then widget:make_image_region(items_img, 480, 16, 16, 16, colonne_p + 72, rangee_p) end

  --Objets quête principale (2)
  local x_tablet = 0
  local y_tablet = 11
  if game:get_value("get_trophy_10001") then widget:make_image_region(items_img, 224, 48, 16, 16, x_tablet + 72, y_tablet + 32) end
  if game:get_value("get_trophy_10002") then widget:make_image_region(items_img, 224, 48, 16, 16, x_tablet + 52, y_tablet) end
  if game:get_value("get_trophy_10003") then widget:make_image_region(items_img, 224, 48, 16, 16, x_tablet + 20, y_tablet) end
  if game:get_value("get_trophy_10004") then widget:make_image_region(items_img, 224, 48, 16, 16, x_tablet + 52, y_tablet + 64) end
  if game:get_value("get_trophy_10005") then widget:make_image_region(items_img, 224, 48, 16, 16, x_tablet + 20, y_tablet + 64) end
  if game:get_value("get_trophy_10006") then widget:make_image_region(items_img, 224, 48, 16, 16, x_tablet, y_tablet + 32) end

  --Jeu terminé
  if game:get_value("boss_key_10000_1") then widget:make_image_region(items_img, 496, 0, 32, 32, x_tablet + 36, y_tablet + 32) end

  --Autres objets
  if game:get_item("quest_items/trophy"):get_variant() == 1 then widget:make_image_region(items_img, 240, 48, 16, 16, colonne_p + 136, rangee_p - 8) end
 
  return widget
end

--FENETRE DES STATISTIQUES: ATTAQUE,DEFENSE,TEMPS DE JEU ET COMPTEUR DE MORTS
local function create_stats_widget(game)
  local widget = gui_designer:create(112, 64)

  widget:set_xy(34, 72)
  --Temps de jeu
  widget:make_image_region(icons_img, 24, 0, 12, 12, 10, 6)
  --Force
  widget:make_image_region(icons_img, 0, 0, 12, 12, 11, 29)
  --Défense
  widget:make_image_region(icons_img, 12, 0, 12, 12, 31, 29)
  --Compteur de morts
  widget:make_image_region(icons_img, 36, 0, 12, 14, 51, 29)
  widget:make_counter(game:get_value("death_counter"), 64, 35)

  return widget
end

--FENETRE DU COMPTEUR D'ÉCLATS DE SOUVENIR
local function create_force_gem_widget(game)
  local widget = gui_designer:create(48, 52)
  widget:set_xy(134, 121)
    local x_gems
    local amount = game:get_item("quest_items/remembrance_shard"):get_amount()
    if amount < 10 then 
      x_gems = 21
      widget:make_counter(amount, x_gems + 7, 19)        
    elseif amount >= 10 and amount < 100 then
      x_gems = 19
      widget:make_counter(amount, x_gems + 7, 19) 
    elseif amount >= 100 and amount < game:get_item("quest_items/remembrance_shard"):get_max_amount() then
      x_gems = 16
      widget:make_counter(amount, x_gems + 7, 19) 
    elseif amount == game:get_item("quest_items/remembrance_shard"):get_max_amount() then
      x_gems = 16
      widget:make_green_counter(amount, x_gems + 7, 19)
    end
    local item_sprite = sol.sprite.create("entities/items")
    item_sprite:set_animation("quest_items/remembrance_shard")
    item_sprite:set_direction(0)
    item_sprite:set_xy(x_gems, 26)
    item_sprite:draw(widget:get_surface())
  return widget
end

--FENETRE DU COMPTEUR DE FRAGMENTS DE PUISSANCE DE FEES
local function create_fairy_power_fragment_widget(game)
  local widget = gui_designer:create(96, 52)
  widget:set_xy(122, 153)
    local x_gems
    local amount = game:get_item("quest_items/fairy_power_fragment"):get_amount()
    if amount < 10 then 
      x_gems = 21
      widget:make_counter(amount, x_gems + 7, 19)        
    elseif amount >= 10 then
      x_gems = 19
      widget:make_counter(amount, x_gems + 7, 19) 
    end
    local item_sprite = sol.sprite.create("entities/items")
    item_sprite:set_animation("quest_items/fairy_power_fragment")
    item_sprite:set_direction(0)
    item_sprite:set_xy(x_gems, 26)
    item_sprite:draw(widget:get_surface())
    local amount_shell = game:get_item("quest_items/shell"):get_amount()
    if amount < 10 then 
      x_gems = 21 + 24
      widget:make_counter(amount_shell, x_gems + 7, 19)        
    elseif amount >= 10 then
      x_gems = 19 + 24
      widget:make_counter(amount_shell, x_gems + 7, 19) 
    end
    local item_sprite = sol.sprite.create("entities/items")
    item_sprite:set_animation("quest_items/shell")
    item_sprite:set_direction(0)
    item_sprite:set_xy(x_gems, 26)
    item_sprite:draw(widget:get_surface())
  return widget
end

function quest_status_manager:new(game)

  local quest_status = {}

  local state = "opening"  -- "opening", "ready" or "closing".

  local menu_title_widget = create_menu_title_widget(game)
  local equipment_items_widget, item_sprites = create_equipment_items_widget(game, item_list)
  local pieces_of_heart_widget = create_pieces_of_heart_widget(game)
  local status_widget = create_status_widget(game)
  local stats_widget = create_stats_widget(game)
  local force_gem_widget = create_force_gem_widget(game)
  local fairy_power_fragment_widget = create_fairy_power_fragment_widget(game)
  
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
        item_assigned_row = math.floor((i - 1) / items_num_columns)
        item_assigned_index = i - 1
      end
    end
  end

  -- Draws the stats of the player (force and defense)
  local force_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }
  local defense_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }

  local function draw_player_stats(dst_surface)
    local force = game:get_value("force")
    force_text:set_text(force)
    force_text:draw(dst_surface, 55, 107) 
    local defense = game:get_value("defense")
    defense_text:set_text(defense)
    defense_text:draw(dst_surface, 77, 107)
  end

  local time_played_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }

  -- Draws the time played on the status widget.
  local function draw_time_played(dst_surface)
    local time_string = game:get_time_played_string()
    time_played_text:set_text(time_string)
    time_played_text:draw(dst_surface, 56, 81)
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

  local cursor_index = game:get_value("pause_quest_status_last_item_index") or 0
  local cursor_row = math.floor(cursor_index / items_num_columns)
  local cursor_column = cursor_index % items_num_columns

  -- Draws cursors on the selected and on the assigned items.
  local function draw_item_cursors(dst_surface)

    -- Selected item.
    local widget_x, widget_y = 16, 119
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
    cursor_index = cursor_row * items_num_columns + cursor_column
    if cursor_index == item_assigned_index then
      item_cursor_moving_sprite:set_animation("solid_fixed")
    end

    local item_name = item_names[cursor_index + 1]
    local item = item_name and item_name ~= "" and game:get_item(item_name) or nil
    local variant = item and item:get_variant() or 0

    if variant > 0 then
      item_caption = sol.language.get_string("quest_status.item_caption." .. item_name .. "." .. variant)
      --game:set_custom_command_effect("action", "info")
    else
      item_caption = nil
      --game:set_custom_command_effect("action", nil)
    end
  end

  function quest_status:on_draw(dst_surface)

    quest_status_background:draw(dst_surface)

    menu_title_widget:draw(dst_surface)
    equipment_items_widget:draw(dst_surface)
    pieces_of_heart_widget:draw(dst_surface)
    status_widget:draw(dst_surface)
    stats_widget:draw(dst_surface)
    force_gem_widget:draw(dst_surface)
    fairy_power_fragment_widget:draw(dst_surface)

    for i, item_sprite in pairs(item_sprites) do
      if not (game:get_item(item_sprite:get_animation()):get_variant()-1 == item_sprite:get_direction()) then
        item_sprite:set_direction(game:get_item(item_sprite:get_animation()):get_variant()-1)
      end
      item_sprite:draw(dst_surface,16,119)
    end

    draw_player_stats(dst_surface)
    draw_time_played(dst_surface)
    -- Show the item cursors and name
    draw_item_cursors(dst_surface)
    draw_item_name(dst_surface)
  end

  function quest_status:on_command_pressed(command)

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
    elseif command == "right" then
      if cursor_column < items_num_columns - 1 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column + 1)
        handled = true
      end

    elseif command == "up" then
      sol.audio.play_sound("cursor")
      if cursor_row > 0 then
        set_cursor_position(cursor_row - 1, cursor_column)
      else
        set_cursor_position(items_num_rows - 1, cursor_column)
      end
      handled = true

    elseif command == "left" then
      if cursor_column > 0 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column - 1)
        handled = true
      end

    elseif command == "down" then
      sol.audio.play_sound("cursor")
      if cursor_row < items_num_rows - 1 then
        set_cursor_position(cursor_row + 1, cursor_column)
      else
        set_cursor_position(0, cursor_column)
      end
      handled = true

    elseif command == "action" then
      --Active the selected Upgrade Card
      local item = game:get_item(item_names[cursor_index + 1])
      if game:has_item(item:get_name()) then
        sol.audio.play_sound("ok")
        if item:get_variant() == 1 then item:set_variant(2) else item:set_variant(1) end
        
      end
      handled = true
    end

    return handled
  end

  function quest_status:on_finished()
    -- Store the cursor position.
    game:set_value("pause_quest_status_last_item_index", cursor_index)
  end

  set_cursor_position(cursor_row, cursor_column)
  state = "ready"

  return quest_status
end

return quest_status_manager