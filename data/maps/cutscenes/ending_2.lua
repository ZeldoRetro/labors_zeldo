local map = ...
local game = map:get_game()

--Défilement des crédits
local credits_roll = sol.surface.create(sol.language.get_language().."/credits/credits_roll.png")
local i = 8
local current_credits = sol.surface.create(sol.language.get_language().."/credits/credits_"..i..".png")
local opacity = 0
current_credits:set_opacity(opacity)
local function fade_in()
	opacity = opacity + 5
	current_credits:set_opacity(opacity)
  if opacity < 255 then
		sol.timer.start(100,fade_in)
  end
end
local function fade_out()
	opacity = opacity - 5
	current_credits:set_opacity(opacity)
  if opacity > 0 then
		sol.timer.start(100,fade_out)
  end
end
function map:on_draw(dst_surface)
  current_credits:draw(dst_surface)
  credits_roll:draw(dst_surface)
end

function map:on_started()
  game:set_hud_enabled(false) 
  game:set_pause_allowed(false)
  hero:set_visible(false)
  sol.audio.play_music("ending",false)

	local movement_viscen_arrive = sol.movement.create("straight")
  movement_viscen_arrive:set_angle(math.pi /2)
	movement_viscen_arrive:set_speed(16)
	movement_viscen_arrive:set_ignore_obstacles()

	movement_viscen_arrive:start(credits_roll)
end

function map:on_opening_transition_finished()
  local movement_hero = sol.movement.create("straight")
  movement_hero:set_angle(0)
  movement_hero:set_speed(20)
  movement_hero:set_max_distance(0)
  hero:freeze()
  movement_hero:start(hero)

  sol.timer.start(map,1000,fade_in)
  sol.timer.start(map,10000,fade_out)
  sol.timer.start(map,16500,function()
    i = i + 1
    current_credits = sol.surface.create(sol.language.get_language().."/credits/credits_"..i..".png")
    current_credits:set_opacity(opacity)
    sol.timer.start(1000,fade_in)
    sol.timer.start(10000,fade_out)
    if i < 19 then return true end
  end)

  sol.timer.start(map,16500 * 12,function()
    hero:teleport("cutscenes/end_screen")
  end)
end

function map:on_key_pressed(key)
  if key == "space" then sol.audio.play_music(nil) hero:teleport("cutscenes/end_screen") end
end

function map:on_joypad_button_pressed(button)
  sol.audio.play_music(nil)
  hero:teleport("cutscenes/end_screen")
end