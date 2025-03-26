-- Initialize block behavior specific to this quest.

-- Variables
local game_meta = sol.main.get_metatable("game")
local combo_timer_duration = 50

-- Include scripts
require("scripts/multi_events")  

---------------------------------
--                             --
--        DANGER ZONE !!!      --
--                             --
---------------------------------
--game_meta.start_attack=function(game)
--  print "huh ?"
--  local hero=game:get_hero()
--  local state, cstate=hero:get_state()
--  if state=="free" or state=="custom" and game:get_sword_ability()>0 and cstate:get_can_use_sword() then
--    hero:swing_sword()
--  end
--end


--[[
 Global override for item use that completely avoids triggering the "item" state and allows full control over item behavior. 
 To enable it, simply define item:start_using() in your item script.
 It also handles a combo system which allows to have a special behavior for both assigned items.
 To enable it, simply define item:start_combo(other) in your script.
  That way, the other item implied in the combo will be passed automatically and you will be able to test for compatibility between both items.
 Notes: 
  if a combo was triggered but no special case was set, then it will first try to fall back to individual item override.
  in your combo override, you wll want to keep it's normal behavior (especially for items with limited amounts) so it doesn"t break them if you ran out of usage of the other item)
  Similarily, if no override was set to single item behavior, then it will fall back to default behavior (item:on_using)
   then it will just be ignored and trigger item:on_using as usual.
  The sword, being an built-in equipment item with it's own command, is not concerned by this system by default.
   However, you can still do combinations by testing for the ability in your item script itself, or even make it an assignable item.
--]]

texte_lieu_on = false
texte_boss_on = false

achievement_display_on = false

local monicle_img = sol.surface.create("backgrounds/monicle.png")
monicle_img:set_opacity(92)

texte_lieu = sol.text_surface.create{
  text = "default",
  font = "alttp",
  font_size = 24,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}
location_text_background = sol.surface.create("menus/location_text_background.png")

achievement_background = sol.surface.create("menus/achievement_background.png")
achievement_title = sol.text_surface.create{
  text = "Achievement",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}
achievement_descr = sol.text_surface.create{
  text = "Achievement descr",
  font = "minecraftia",
  font_size = 8,
  horizontal_alignment = "left",
  vertical_alignment = "middle",
}

game_meta:register_event("on_draw",function(game,dst_surface)
  local map = game:get_map()
  local hero = map:get_hero()

  --EFFET MONOCLE DE VERITE
  if game:get_value("monicle_active") then
    monicle_img:draw(dst_surface)
  end


  --AFFICHAGE LIEU
  if texte_lieu_on then 
    location_text_background:draw(dst_surface)
    texte_lieu:draw(dst_surface, 8, 56) 
  end
  --AFFICHAGE BOSS
  --if texte_boss_on then texte_boss:draw(dst_surface) end

  --AFFICHAGE SUCCÈS
  if achievement_display_on then 
    achievement_background:draw(dst_surface, -224)
    achievement_title:draw(dst_surface, 28, 194)
    achievement_descr:draw(dst_surface, 28, 194)
  end
end)


game_meta:register_event("on_command_pressed", function(game, command)
    local hero=game:get_hero()
    local state, cstate=hero:get_state()
    if command == "attack"  and not game:is_suspended() then

    elseif command == "item_1" or command =="item_2" then
--    if command == "item_1" or command =="item_2" then
--      debug_print "item_command ?"
      if not game:is_suspended() then
        local item_1 = game:get_item_assigned("1")
        local item_2 = game:get_item_assigned("2")
        --if no item was assigned at this point, or if no override was added to assigned items, then do not go further
        if command=="item_1" and not item_1 or command=="item_2" and not item_2 then
          return
        end

        local name_1 = item_1 and item_1:get_name() or ""
        local name_2 = item_2 and item_2:get_name() or ""   

        --mark items as triggered
        local handled = false

        local function try_combo()
--          debug_print "in try_combo function"
          if game.item_combo ~= true and game.last_item_1~=nil and game.last_item_2~=nil then
--            debug_print "Combination detected"

            sol.timer.start(game, combo_timer_duration+10, function()
--                debug_print "Reset combo status"
                game.item_combo=nil
              end)

            --Both items are trying to be used at the same time, so try to start the combo for them
            if item_1 and item_1.start_combo then
              game.item_combo=true
--              debug_print ("Using combined behavior for item 1 ("..name_1..") with "..name_2)
              item_1:start_combo(item_2)
              return true
            elseif item_2 and item_2.start_combo then
              game.item_combo=true
--              debug_print ("Using combined behavior for item 2 ("..name_2..") with "..name_1)
              item_2:start_combo(item_1)
              return true
            end
          end
        end

        if command =="item_1" and item_1~=nil then
          if state=="custom" then --Prevent item to trigger if custom state rules forbids it 
            if not cstate:get_can_use_item(name_1) then
              return true
            end
          end
--          debug_print "Item 1 triggered"
          game.last_item_1=name_1
          handled = item_1.start_using ~= nil or item_1.start_combo ~= nil
          sol.timer.start(game, combo_timer_duration+10, function()
              --Delay resetting combo register for next cycle after combo checking
--              debug_print "Item 1 resetted"
              game.last_item_1=nil
            end)
          if game.last_item_2~=nil then
---           debug_print "Combo from item 1"
            if try_combo() then
--              debug_print "Combo 1 OK"
              return true --Combo was successfull, stop propagating command
            end
          end

        elseif command == "item_2" and item_2~=nil then
          if state=="custom" then --Prevent item to trigger if custom state rules forbids it 
            if not cstate:get_can_use_item(name_2) then
              return true
            end
          end
--          debug_print "Item 2 triggered"
          game.last_item_2=name_2
          handled = item_2.start_using ~= nil or item_2.start_combo ~= nil
          sol.timer.start(game, combo_timer_duration+10, function()
              --Delay resetting combo registers for next cycle after combo_checking
--              debug_print "Item 2 resetted"
              game.last_item_2=nil  
            end)

          if game.last_item_1~=nil then
--            debug_print "combo from item 2"
            if try_combo() then
--              debug_print "combo 2 OK"
              return true
            end
          end

        end
--        debug_print "starting single-item check timer"
        --At this point, no combo was triggered, so we start the combo cancelling timer
        --This timer ensures we have enough time to press the other command before falling back to single-item behavior.
        sol.timer.start(game, combo_timer_duration, function()
--            debug_print "checking for single item"
            --At this point, the combo was not triggered at all
            --or has already been handled in a previous cycle and not been cleaned yet
            --so we try using the normal override on each item instead.
            if game.item_combo==nil then
              if game.last_item_1 and item_1.start_using~=nil then
--                            debug_print "item 1"
                item_1:start_using()
                return
              elseif game.last_item_2 and item_2.start_using~=nil then
                item_2:start_using()
--                debug_print "item 2"
                return
              end
            end
            --if we reached this point then it means that the item had no override (and the execution will now default to the built-in bahavior)
--            debug_print "Back to default behavior"
          end)
        return handled
      end
    end
  end)
