-- Statistics screen about completing the game.

local stats_manager = { }

local gui_designer = require("scripts/menus/lib/gui_designer")

local menu_background_curtain_1 = sol.surface.create("menus/stats_labors_curtain_1.png")
local menu_background_curtain_2 = sol.surface.create("menus/stats_labors_curtain_2.png")
local menu_background_curtain_3 = sol.surface.create("menus/stats_labors_curtain_3.png")

local menu_background = sol.surface.create("menus/stats_labors_background.png")
local ending_background = sol.surface.create("menus/ending.png")

local menu_background_picture

local can_skip = false

local function create_menu_title_widget(game)
  local widget = gui_designer:create(88, 28)
  widget:set_xy(16, 8)
  widget:make_text(sol.language.get_string("stats_menu.title"), 6, 6, "left")
  return widget
end

function stats_manager:new(game)

  sol.audio.play_music("creations/labors/results_screen")

  local stats = {}

  local layout
  local death_count
  local num_pieces_of_heart
  local max_pieces_of_heart
  local num_items
  local max_items
  local num_items_inventory
  local max_items_inventory
  local num_items_dungeons
  local max_items_dungeons
  local num_items_main_quest
  local max_items_main_quest
  local num_force_gems
  local max_force_gems
  local percent
  local tr = sol.language.get_string

  local menu_title_widget = create_menu_title_widget(game)

  local function get_game_time_string()
    return tr("stats_menu.game_time") .. " " .. game:get_time_played_string()
  end

  local function get_death_count_string()
    death_count = game:get_value("death_counter") or 0
    return tr("stats_menu.death_count"):gsub("%$v", death_count)
  end

  local function get_pieces_of_heart_string()
    local item = game:get_item("quest_items/piece_of_heart")
    num_pieces_of_heart = item:get_total_pieces_of_heart()
    --max_pieces_of_heart = item:get_max_pieces_of_heart()
    return tr("stats_menu.pieces_of_heart") .. " "  ..
        num_pieces_of_heart --.. " / " .. max_pieces_of_heart
  end

  local function get_items_inventory_string()

    num_items_inventory = 0
    if game:get_value("labors_bottle_1_wave_1") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("labors_bottle_2_wave_1") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("labors_quiver_wave_1") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("labors_bomb_bag_wave_1") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("labors_magic_flask_upgrade_wave_1") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("labors_defense_boost_wave_1") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("labors_attack_boost_wave_1") then num_items_inventory = num_items_inventory + 1 end
    max_items_inventory = 7
    return tr("stats_menu.items_inventory") .. " " .. num_items_inventory .. " / "  ..max_items_inventory
  end

  local function get_items_dungeons_string()

    num_items_dungeons = 0
    if game:get_value("red_key_10000_1_1") then num_items_dungeons = num_items_dungeons + 1 end
    if game:get_value("blue_key_10000_1_1") then num_items_dungeons = num_items_dungeons + 1 end
    if game:get_value("green_key_10000_1_1") then num_items_dungeons = num_items_dungeons + 1 end
    if game:get_value("yellow_key_10000_1") then num_items_dungeons = num_items_dungeons + 1 end
    max_items_dungeons = 4
    return tr("stats_menu.items_dungeons") .. " " .. num_items_dungeons .. " / "  ..max_items_dungeons
  end

  local function get_items_main_quest_string()

    num_items_main_quest = 0
    if game:get_value("get_trophy_10001") then num_items_main_quest = num_items_main_quest + 1 end
    if game:get_value("get_trophy_10002") then num_items_main_quest = num_items_main_quest + 1 end
    if game:get_value("get_trophy_10003") then num_items_main_quest = num_items_main_quest + 1 end
    if game:get_value("get_trophy_10004") then num_items_main_quest = num_items_main_quest + 1 end
    if game:get_value("get_trophy_10005") then num_items_main_quest = num_items_main_quest + 1 end
    if game:get_value("get_trophy_10006") then num_items_main_quest = num_items_main_quest + 1 end
    max_items_main_quest = 6
    return tr("stats_menu.items_main_quest") .. " " .. num_items_main_quest .. " / "  ..max_items_main_quest
  end

  local function get_force_gems_string()

    num_force_gems = game:get_value("remembrance_shard_found")
    max_force_gems = 100

    return tr("stats_menu.force_gems") .. " " .. num_force_gems .. " / "  ..max_force_gems
  end

  local function get_percent_string()
    local current = num_force_gems + num_items_inventory + num_items_dungeons + num_items_main_quest
    local max = max_force_gems + max_items_inventory + max_items_dungeons + max_items_main_quest
    percent = math.floor(current / max * 100)
    return tr("stats_menu.percent"):gsub("%$v", percent)
  end

  local function get_rank_string()
    if percent == 100 then
      return tr("stats_menu.final_rank_platinum")
    elseif percent <= 99 and percent >= 90 then
      return tr("stats_menu.final_rank_gold")
    elseif percent <= 89 and percent >= 60 then
      return tr("stats_menu.final_rank_silver")
    else
      return tr("stats_menu.final_rank_bronze")
    end
  end

  local function build_layout(page)

    layout = gui_designer:create(320, 240)

    local y = 24
    local x = 16
    y = y + 24

    --STATS GÉNÉRALES : MORTS, TEMPS DE JEU ET DIFFICULTÉ
    layout:make_text(get_game_time_string(), x, y)
    y = y + 16
    layout:make_text(get_death_count_string(), x, y)
    y = y + 24

    --STATS DE COMPLÉTION : TROPHÉES CLÉS ET AUTRES
    layout:make_text(get_items_main_quest_string(), x, y)
    y = y + 16
    layout:make_text(get_items_dungeons_string(), x, y)
    y = y + 16
    layout:make_text(get_force_gems_string(), x, y)
    y = y + 16
    layout:make_text(get_items_inventory_string(), x, y)
    y = y + 24
    layout:make_text(get_percent_string(), x, y)
    y = y + 16
    layout:make_text(get_rank_string(), x, y)
    y = y + 32
    layout:make_text(sol.language.get_string("stats_menu.end"), x, y)

  end

  build_layout(page)

  function stats:on_command_pressed(command)

    local handled = false
    if command == "action" then

      if not can_skip then return end
      game:set_value("game_finished",true)

      sol.audio.play_music("none")
      sol.audio.play_sound("ending_fade")

      ending_background:fade_in(130,function()
        game:save()
        sol.main.reset()
      end)

      return true
    end
    return handled
  end

  function stats:on_started()
    if percent == 100 then
      menu_background_picture = sol.surface.create("menus/stats_picture_platinum.png")
      game:set_value("door_platinum_rank_10000_1_opened",true)
    elseif percent <= 99 and percent >= 90 then
      menu_background_picture = sol.surface.create("menus/stats_picture_gold.png")
    elseif percent <= 89 and percent >= 60 then
      menu_background_picture = sol.surface.create("menus/stats_picture_silver.png")
    else
      menu_background_picture = sol.surface.create("menus/stats_picture_bronze.png")
    end
    ending_background:set_opacity(0)
    sol.timer.start(stats,2000,function()
      menu_background_curtain_1:fade_out(100,function()
        sol.timer.start(stats,3000,function()
          menu_background_curtain_2:fade_out(100,function()
            sol.timer.start(stats,1000,function()
              menu_background_curtain_3:fade_out(100,function() can_skip = true end)
            end)
          end)
        end)
      end)
    end)
  end

  function stats:on_draw(dst_surface)
    menu_background:draw(dst_surface)
    menu_background_picture:draw(dst_surface)
    layout:draw(dst_surface)
    menu_title_widget:draw(dst_surface)

    menu_background_curtain_1:draw(dst_surface)
    menu_background_curtain_2:draw(dst_surface)
    menu_background_curtain_3:draw(dst_surface)

    ending_background:draw(dst_surface)
  end

  return stats
end

gui_designer:map_joypad_to_keyboard(stats_manager)

return stats_manager