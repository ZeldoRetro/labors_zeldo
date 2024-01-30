local item = ...
local game = item:get_game()

function item:on_created()

  self:set_savegame_variable("possession_ocarina")
  self:set_assignable(true)

end


function item:on_using()
  self:set_finished()
end

function item:playing_song(music,time,callback)
          
  local map = game:get_map()
  local hero = map:get_hero()
  local volume_before = sol.audio.get_music_volume()
  local x,y,layer = hero:get_position()
  hero:freeze()
  hero:set_animation("playing_ocarina")
  local notes = map:create_custom_entity{
    x = x,
    y = y,
    layer = layer + 1,
    width = 24,
    height = 32,
    direction = 0,
    sprite = "entities/notes"
  }
  local notes2 = map:create_custom_entity{
    x = x,
    y = y,
    layer = layer + 1,
    width = 24,
    height = 32,
    direction = 2,
    sprite = "entities/notes"
  }
  sol.audio.set_music_volume(0)
  sol.audio.play_sound(music)
  game:set_suspended(true)
  hero:get_sprite():set_ignore_suspend(true)
  notes:get_sprite():set_ignore_suspend(true)
  notes2:get_sprite():set_ignore_suspend(true)
  game:set_pause_allowed(false)
  sol.timer.start(game, time, function()
    hero:unfreeze()
    hero:get_sprite():set_ignore_suspend(false)
    game:set_suspended(false)
    game:set_pause_allowed(true)
    notes:remove()
    notes2:remove()
    sol.audio.set_music_volume(volume_before)
    if callback ~= nil then
      callback()
    end
  end)

end

