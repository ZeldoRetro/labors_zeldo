local fsa = {}

local light_mgr = require("scripts/lights/light_manager")

local quest_w, quest_h = sol.video.get_quest_size()

local tmp = sol.surface.create(sol.video.get_quest_size())
local fsa_texture = sol.surface.create(sol.video.get_quest_size())

local half_screen_scale = 1 / 1
local half_screen = sol.surface.create(quest_w * half_screen_scale, quest_h * half_screen_scale)
half_screen:set_scale(1 / half_screen_scale, 1 / half_screen_scale)
half_screen:set_blend_mode("add")
local glow_acc = sol.surface.create(quest_w, quest_h)
glow_acc:set_blend_mode("add")

local clouds_shadow = sol.surface.create("backgrounds/clouds_shadow.png")
clouds_shadow:set_blend_mode("multiply")

local effect = sol.surface.create"backgrounds/fsaeffect.png"
--effect:set_blend_mode"multiply"
local shader = sol.shader.create"water_effect"

shader:set_uniform("fsa_texture", fsa_texture)

tmp:set_shader(shader)
local ew,eh = effect:get_size()

local clouds_speed = 0.01

local csw,csh = clouds_shadow:get_size()

--draw cloud shadow
function fsa:draw_clouds_shadow(dst,cx,cy)
  local t = sol.main.get_elapsed_time() * clouds_speed;
  local x,y = math.floor(t),math.floor(t)
  local cw,ch = dst:get_size()
  local tx,ty = (-cx+x) % csw, (-cy+y) % csh
  local imax = math.ceil(cw/csw)
  local jmax = math.ceil(ch/csh)
  for i=-1,imax do
    for j=-1,jmax do
      clouds_shadow:draw(dst,tx+i*csw,ty+j*csh)
    end
  end
end

-- read map file again to get lights position
local function get_lights_from_map(map)
  local map_id = map:get_id()
  local lights = {}
  -- Here is the magic: set up a special environment to load map data files.
  local environment = {
  }

  local big = "110"
  local small = "80"

  local radii = {
    ["torch"] = small,
    ["torch_big.top"] = small,
  }

  local win_cut = "0.1"
  local win_aperture = "0.707"

  local dirs = {
    ["window.1-1"] = "0,1",
    ["window.2-1"] = "0,-1",
    ["window.3-1"] = "1,0",
    ["window.4-1"] = "-1,0",
  }

  local win_col = "128,128,255"
  local colors = {
    ["window.1-1"] = win_col,
    ["window.2-1"] = win_col,
    ["window.3-1"] = win_col,
    ["window.4-1"] = win_col,
  }

  -- Make any other function a no-op (tile(), enemy(), block(), etc.).
  setmetatable(environment, {
    __index = function()
      return function() end
    end
  })

  -- Load the map data file as Lua.
  local chunk = sol.main.load_file("maps/" .. map_id .. ".dat")

  -- Apply our special environment (with functions properties() and chest()).
  setfenv(chunk, environment)

  -- Run it.
  chunk()
  return lights
end

--render fsa texture to fsa effect map
function fsa:render_fsa_texture(map)
  fsa_texture:clear()
  if false and not self.outside then
    fsa_texture:fill_color{255,255,255}
    return
  end
  local cw,ch = fsa_texture:get_size()
  local camera = map:get_camera()
  local dx,dy = camera:get_position()
  local tx = ew - dx % ew
  local ty = eh - dy % eh
  for i=-1,math.ceil(cw/ew) do
    for j=-1,math.ceil(ch/eh) do
      effect:draw(fsa_texture,tx+i*ew,ty+j*eh)
    end
  end
end


-- create a light that will automagically register to the light_manager
function create_light(map, x, y, layer, radius, color, dir, cut, aperture, distort_angle)
  local function dircutappprops()
    if dir and cut and aperture then
      return {key="direction",value=dir},
      {key="cut",value=cut},
      {key="aperture",value=aperture}
    end
  end
  return map:create_custom_entity{
    direction=0,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
    sprite = "entities/fire_mask",
    model = "light",
    properties = {
      {key="radius",value = radius},
      {key="color",value = color},
      {key=distort_angle and "distort_angle" or "no_distort", value = tostring(distort_angle) or "0"}, -- TODO find better way
      dircutappprops()
    }
  }
end

local function setup_inside_lights(map)
  light_mgr:init(map,
                 (function()
                    if map:get_game():get_value("dark_room") then return {12,12,12}
                    elseif map:get_game():get_value("dark_room_middle") then return {128,128,128}
                    elseif map:is_outside() then
                      if map:get_game():get_value("night") then return {0,33,164}
                      elseif map:get_game():get_value("dawn") then return {255,94,109}
                      else return {255,255,255}
                      end
                    end
                 end)())
  light_mgr:add_occluder(map:get_hero())


    local hero = map:get_hero()
    --create hero light if the player has the lamp
    if map:get_game():has_item("inventory/lamp") then
      local hl = create_light(map,0,0,0,"80","240,210,15")
      function hl:on_update()
        hl:set_position(hero:get_position())
      end
      hl.excluded_occs = {[hero]=true}
    end

  --add a static light for each torch pattern in the map
  local map_lights = get_lights_from_map(map)
  local default_radius = "160"
  local default_color = "240,210,15"

  for _,l in ipairs(map_lights) do
    create_light(map,l.x,l.y,l.layer,l.radius or default_radius,l.color or default_color,
                 l.dir,l.cut,l.aperture,l.distort_angle)
  end


  --TODO add other non-satic occluders
  for en in map:get_entities_by_type("enemy") do
    --light_mgr:add_occluder(en)
    if en:get_breed() == "bubble_red" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,"80","245,50,50")
      light:set_enabled(true)
      function light:on_update() light:set_position(en:get_position()) end
      function en:on_removed() light:set_enabled(false) end
      function en:on_enabled() light:set_enabled(true) end
      function en:on_disabled() light:set_enabled(false) end
    end
    if en:get_breed() == "boss/mothula_ring" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,"80","245,50,50")
      light:set_enabled(true)
      function light:on_update() light:set_position(en:get_position()) end
      function en:on_removed() light:set_enabled(false) end
      function en:on_enabled() light:set_enabled(true) end
      function en:on_disabled() light:set_enabled(false) end
    end
    if en:get_breed() == "bubble_green" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,"80","50,200,50")
      light:set_enabled(true)
      function light:on_update() light:set_position(en:get_position()) end
      function en:on_removed() light:set_enabled(false) end
    end
    if en:get_breed() == "bubble_blue" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,"80","80,70,222")
      light:set_enabled(true)
      function light:on_update() light:set_position(en:get_position()) end
      function en:on_removed() light:set_enabled(false) end
      function en:on_enabled() light:set_enabled(true) end
      function en:on_disabled() light:set_enabled(false) end
    end
    if en:get_breed() == "bubble_dark" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,"80","150,30,160")
      light:set_enabled(true)
      function light:on_update() light:set_position(en:get_position()) end
      function en:on_removed() light:set_enabled(false) end
    end
  end
  
  for en in map:get_entities_by_type("npc") do
    light_mgr:add_occluder(en)
  end

  for en in map:get_entities_by_type("pickable") do
    if en:get_name() ~= nil then
      if en:get_name():match("^fairy_power_fragment") then
        local tx,ty,tl = en:get_position()
        local tw,th = en:get_size()
        local yoff = -8
        local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,"165","250,110,230")
        light:set_enabled(true)
        function en:on_removed() light:set_enabled(false) end
      end
    end
  end

  --generate lights for dynamic torches
  for en in map:get_entities_by_type("custom_entity") do
    if en:get_model() == "torch" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,default_radius,default_color)
      en:register_event("on_unlit",function()
                          light:set_enabled(false)
      end)
      en:register_event("on_lit",function()
                          light:set_enabled(true)
      end)
      light:set_enabled(en:is_lit())
    end
    if en:get_model() == "ocarina_path" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,default_radius,default_color)
      if en:get_sprite():get_animation() == "linked" then
        light:set_enabled(true)
      else
        light:set_enabled(false)
      end
    end
  end
end

function fsa:on_map_changed(map)
  if self.current_map == map then
    return -- already registered and created
  end
  local outside = map:is_outside()
  setup_inside_lights(map)
  self.outside = outside
  self.current_map = map
end

function fsa:on_map_draw(map, dst)
  --dst:set_shader(shader)
  dst:draw(tmp)

  fsa:render_fsa_texture(map)

  
  local camera = map:get_camera()
  local dx,dy = camera:get_position()
  local cw, ch = camera:get_size()
  local layer = map:get_hero():get_layer()
 

  tmp:set_shader(shader)
  tmp:draw(dst)

  light_mgr:draw(dst,map)

  if self.outside then
    if map:get_id() == "creations/forgotten_legend/outside/light/A4"
    or map:get_id() == "creations/forgotten_legend/outside/light/A5"
    or map:get_id() == "creations/another_hyrule_fantasy/outside/light/A4" 
    or map:get_id() == "creations/forgotten_legend/outside/light/sacred_forest_meadow" then return end
  if map:get_entity("init_map") ~= nil and map:get_entity("init_map"):get_property("disable_clouds") ~= nil then return end
    fsa:draw_clouds_shadow(dst,dx,dy)
  end
end

function fsa:clean()

end

return fsa
