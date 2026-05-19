-- The clock shows the cycle of the Time.

local clock_builder = {}

local clock_img = sol.sprite.create("hud/clock_daytime")

function clock_builder:new(game)

  local clock = {}

  function clock:set_dst_position(x, y)
    self.dst_x = x
    self.dst_y = y
  end

  function clock:on_draw(dst_surface)

    local x, y = self.dst_x, self.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    if daytime_increment then clock_img:draw(dst_surface, x + 18, y + 29) clock_img:set_animation("cycle_"..(game:get_value("daytime") - 1).."_to_"..game:get_value("daytime"))
    else clock_img:draw(dst_surface, x + 18, y + 29) clock_img:set_animation("cycle_"..game:get_value("daytime") - 1) end

  end

  return clock
end

return clock_builder