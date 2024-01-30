local item = ...

function item:on_created()
  self:set_savegame_variable("possession_feather")
  self:set_assignable(true)
end

function item:on_using()

  local hero = self:get_map():get_entity("hero")
  local direction4 = hero:get_direction()
  local magic_needed = 2  -- Number of magic points required

  if self:get_game():get_magic() >= magic_needed then
    sol.audio.play_sound("jump")
    self:get_game():remove_magic(magic_needed)
    hero:start_jumping(direction4 * 2, 48, false)
  else
    sol.audio.play_sound("wrong")
    item:get_game():start_dialog("_need_magic")
  end

  item:set_finished()
end
