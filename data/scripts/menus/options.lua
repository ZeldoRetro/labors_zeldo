local options_menu = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local layout
local cursor_img = sol.sprite.create("menus/arrow")
cursor_img:set_animation("blinking")
local slider_img = sol.surface.create("menus/slider.png")
local cursor_position
local music_slider_x
local sound_slider_x
local slider_cursor_img = sol.surface.create("menus/slider_cursor.png")
local languages = sol.language.get_languages()
local language_index
local records = require("scripts/records_manager")
local last_option
local link_voice_option
local link_voice_manager = require("scripts/link_voice_manager")

local background_img = sol.surface.create(320,240)
background_img:fill_color({255,255,255})
local background_slabs_img = sol.surface.create("menus/title_labors_background.png")

local background_file_select = sol.surface.create("menus/options_labors_background.png")

-- Cursor position:
-- 1: music volume
-- 2: sound volume
-- 3: Link Voice
-- 4: video filter
-- 5: language
-- 6: back
local cursor_position
local shader

local function build_layout()

  layout = gui_designer:create(320, 240)

  layout:make_wooden_frame(16, 8, 160, 32)
  layout:make_text(sol.language.get_string("options_menu.title"), 95, 16, "center")
  layout:make_text(sol.language.get_string("options_menu.music_volume"), 64, 56)
  layout:make_image(slider_img, 128, 56)
  layout:make_text(sol.language.get_string("options_menu.sound_volume"), 64, 80)
  layout:make_image(slider_img, 128, 80)
  layout:make_text(sol.language.get_string("options_menu.link_voice"), 64, 104)
  if link_voice_manager:get_link_voice_enabled() then link_voice_option = "options_menu.link_voice_yes"
  else link_voice_option = "options_menu.link_voice_no" end
  layout:make_text("< " .. sol.language.get_string(link_voice_option) .. " >", 288, 104, "right")
  layout:make_text(sol.language.get_string("options_menu.video_filter"), 64, 128)
  if sol.video.get_shader()== nil then layout:make_text("< " .. sol.language.get_string("options_menu.video_filter_nil") .. " >", 288, 128, "right")
  else shader = sol.video.get_shader() layout:make_text("< " .. shader:get_id() .. " >", 288, 128, "right") end
  layout:make_text(sol.language.get_string("options_menu.language"), 64, 152)
  layout:make_text("< " .. sol.language.get_language_name() .. " >", 288, 152, "right")
  layout:make_text(sol.language.get_string("options_menu.back"), 64, 200)
end

-- Places the cursor on option 1, 2 or 3, 4
-- or on the back button (5).
local function set_cursor_position(index)

  cursor_position = index
  cursor_img:set_xy(28, 28 + index * 24)
  if cursor_position == 1 then cursor_img:set_xy(28, 56)
  elseif cursor_position == 2 then cursor_img:set_xy(28, 80)
  elseif cursor_position == 3 then cursor_img:set_xy(28, 104)
  elseif cursor_position == 4 then cursor_img:set_xy(28, 128)
  elseif cursor_position == 5 then cursor_img:set_xy(28, 152) 
  elseif cursor_position == 6 then cursor_img:set_xy(28, 200) end
end

local function update_music_slider()

  local volume = sol.audio.get_music_volume()
  music_slider_x = 136 + (volume * 128 / 100)
end

local function update_sound_slider()

  local volume = sol.audio.get_sound_volume()
  sound_slider_x = 136 + (volume * 128 / 100)
end

local function increase_music_volume()

  local volume = sol.audio.get_music_volume()
  if volume < 100 then
    volume = volume + 10
    sol.audio.set_music_volume(volume)
    update_music_slider()
  end
end

local function decrease_music_volume()

  local volume = sol.audio.get_music_volume()
  if volume > 0 then
    volume = volume - 10
    sol.audio.set_music_volume(volume)
    update_music_slider()
  end
end

local function increase_sound_volume()

  local volume = sol.audio.get_sound_volume()
  if volume < 100 then
    volume = volume + 10
    sol.audio.set_sound_volume(volume)
    update_sound_slider()
  end
end

local function decrease_sound_volume()

  local volume = sol.audio.get_sound_volume()
  if volume > 0 then
    volume = volume - 10
    sol.audio.set_sound_volume(volume)
    update_sound_slider()
  end
end

local function toggle_link_voice_option()
  if link_voice_manager:get_link_voice_enabled() then 
    link_voice_manager:set_link_voice_disabled()
  else link_voice_manager:set_link_voice_enabled() end
  link_voice_manager:save()
  build_layout()
end

local function previous_video_mode()

  if sol.video.get_shader() == nil then
	shader = sol.shader.create("sepia")
  elseif shader:get_id() == "sepia" then
  shader = sol.shader.create("ntsc2pal")
  elseif shader:get_id() == "ntsc2pal" then
  shader = sol.shader.create("heavybloom")
  elseif shader:get_id() == "heavybloom" then
  shader = sol.shader.create("6xbrz")
  elseif shader:get_id() == "6xbrz" then
  shader = sol.shader.create("hq2x")
  elseif shader:get_id() == "hq2x" then
	shader = nil
  end
	sol.video.set_shader(shader)
  build_layout()
end

local function next_video_mode()

  if sol.video.get_shader() == nil then
  shader = sol.shader.create("hq2x")
  elseif shader:get_id() == "hq2x" then
  shader = sol.shader.create("6xbrz")
  elseif shader:get_id() == "6xbrz" then
  shader = sol.shader.create("heavybloom")
  elseif shader:get_id() == "heavybloom" then
  shader = sol.shader.create("ntsc2pal")
  elseif shader:get_id() == "ntsc2pal" then
  shader = sol.shader.create("sepia")
  elseif shader:get_id() == "sepia" then
  shader = nil
  end
	sol.video.set_shader(shader)
  build_layout()
end

local function previous_language()

  language_index = ((language_index - 2) % #languages) + 1
  sol.language.set_language(languages[language_index])
  build_layout()
end

local function next_language()

  language_index = (language_index % #languages) + 1
  sol.language.set_language(languages[language_index])
  build_layout()
end

function options_menu:on_started()

  records:load()
  build_layout()
  set_cursor_position(6)  -- Back.
  update_music_slider()
  update_sound_slider()

  for i, language in ipairs(languages) do
    if language == sol.language.get_language() then
      language_index = i
    end
  end
end

function options_menu:on_draw(dst_surface)

  background_img:draw(dst_surface)
  background_slabs_img:draw(dst_surface)
  background_file_select:draw(dst_surface)

  layout:draw(dst_surface)
  cursor_img:draw(dst_surface)
  slider_cursor_img:draw(dst_surface, music_slider_x, 56)
  slider_cursor_img:draw(dst_surface, sound_slider_x, 80)
end

function options_menu:on_key_pressed(key)

  if key == "down" then
    sol.audio.play_sound("save_menu_cursor")
    if cursor_position < 6 then
      set_cursor_position(cursor_position + 1)
    else
      set_cursor_position(1)
    end
  elseif key == "up" then
    sol.audio.play_sound("save_menu_cursor")
    if cursor_position > 1 then
      set_cursor_position(cursor_position - 1)
    else
      set_cursor_position(6)
    end
  elseif key == "left" then
    if cursor_position == 1 then
      decrease_music_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 2 then
      decrease_sound_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 3 then
      toggle_link_voice_option()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 4 then
      previous_video_mode()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 5 then
      previous_language()
      sol.audio.play_sound("pause_turn")
    end
  elseif key == "right" then
    if cursor_position == 1 then
      increase_music_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 2 then
      increase_sound_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 3 then
      toggle_link_voice_option()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 4 then
      next_video_mode()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 5 then
      next_language()
      sol.audio.play_sound("pause_turn")
    end
  elseif key == "space" then
    if cursor_position == 6 then
      sol.audio.play_sound("save_menu_cancel")
      sol.menu.stop(options_menu)
    end
  end

  -- Don't forward the key event to the savegame menu below.
  return true
end

-- Creates a popup with information about the selected rank.
-- TODO this could be in gui_designer
function show_popup()

  local popup = {}
  local text
  if records:get_rank_100_percent() and records:get_rank_speed() and records:get_rank_ultimate() then
    text = sol.language.get_string("options_menu.cheats_unlocked")
    sol.audio.play_sound("secret")
    if not sol.file.exists("debug_player.dat") then
      local file = sol.file.open("debug_player.dat", "w")
      file:write("1")
    end
  else
    text = sol.language.get_string("options_menu.need_achievements")
    sol.audio.play_sound("wrong")
  end

  assert(text ~= nil)

  local max_width = 0
  local total_height = 0
  local lines = {}
  for line in text:gmatch("[^$]+") do
    local line_text = sol.text_surface.create({
      font = "alttp",
      text = line,
    })
    local width, height = line_text:get_size()
    max_width = math.max(width, max_width)
    total_height = total_height + height
    lines[#lines + 1] = line
  end
  max_width = max_width + 16  -- Extra space for borders.
  total_height = total_height + 16
  local screen_width, screen_height = sol.video.get_quest_size()
  local popup_x = screen_width / 2 - max_width / 2
  local popup_y = screen_height / 2 - total_height / 2

  local layout = gui_designer:create(max_width, total_height)
  layout:make_wooden_frame()
  local y = 8
  for _, line in ipairs(lines) do
    layout:make_text(line, 8, y)
    y = y + 16
  end

  function popup:on_key_pressed(key)

    if key == "space" then
      sol.menu.stop(popup)
    end

    return true
  end

  function popup:on_draw(dst_surface)

    layout:draw(dst_surface, popup_x, popup_y)
  end

  gui_designer:map_joypad_to_keyboard(popup)
  sol.menu.start(options_menu, popup)
end

gui_designer:map_joypad_to_keyboard(options_menu)

return options_menu
