local music_data = require("scripts/data/music_data")

---@class array<T>: { [integer]: T }
---@class dict<T>: { [string]: T }

---@class zeldo.layer_music
---@field id string
---@field stages dict<zeldo.layer_music.stage>
---@field play? fun(self)
---@field stop? fun(self)
---@field set_stage? fun(self, name: string)

---@class zeldo.layer_music.stage

---Create a layer music from it file
---@param map table
---@param id string
---@return zeldo.layer_music
local function create_layer_music(map, id)

    ---@type zeldo.layer_music
    local layer_music = {
        id = id,
        stages = music_data[id].stages,
    }

    function layer_music:play()
        sol.audio.play_music(self.id)
    end

    function layer_music:stop()
        sol.audio.stop_music()
    end

    function layer_music:set_stage(name)
        local channels = self.stages[name]
        for channel, volume in pairs(channels) do
            ---print(channel, volume)
            sol.audio.set_music_channel_volume(channel - 1, volume)
        end
    end

    return layer_music
end

return create_layer_music
