--= save_load.lua =--
-- Handles game save and load functionality for local storage with multiple save slots.

local saveLoad = {}
local json = require("dkjson") -- Using dkjson for encoding/decoding JSON
local gameState = require("game_state")

local SAVE_DIR = "saves/" -- Directory to store save files
love.filesystem.createDirectory(SAVE_DIR) -- Ensure the save directory exists

local selectedSlot = 1 -- Default selected slot

-- Save the current game state to a specified slot
function saveLoad.saveGame(slot)
    local saveFile = SAVE_DIR .. "save_" .. tostring(slot) .. ".json"
    local data = json.encode(gameState.gameState, { indent = true })
    local success, message = love.filesystem.write(saveFile, data)
    
    if success then
        print("Game successfully saved to slot " .. slot)
    else
        print("Error saving game: " .. message)
    end
end

-- Load a saved game state from a specified slot
function saveLoad.loadGame(slot)
    local saveFile = SAVE_DIR .. "save_" .. tostring(slot) .. ".json"
    
    if not love.filesystem.getInfo(saveFile) then
        print("No save file found in slot " .. slot)
        return false
    end
    
    local data, size = love.filesystem.read(saveFile)
    if data then
        local decoded, pos, err = json.decode(data)
        if decoded then
            gameState.gameState = decoded
            print("Game successfully loaded from slot " .. slot)
            return true
        else
            print("Error loading save file: " .. err)
            return false
        end
    else
        print("Failed to read save file.")
        return false
    end
end

-- Get a list of available save slots
function saveLoad.getSaveSlots()
    local files = love.filesystem.getDirectoryItems(SAVE_DIR)
    local slots = {}
    for _, file in ipairs(files) do
        local slot = file:match("save_(%d+)%.json")
        if slot then
            table.insert(slots, tonumber(slot))
        end
    end
    table.sort(slots)
    return slots
end

-- Draw UI for selecting save slots
function saveLoad.drawUI()
    love.graphics.print("Select Save Slot:", 50, 50)
    local slots = saveLoad.getSaveSlots()
    
    for i = 1, 5 do  -- Display 5 slots (1-5)
        local text = "Slot " .. i
        if i == selectedSlot then
            text = "> " .. text .. " <"
        end
        love.graphics.print(text, 50, 70 + (i * 20))
    end
end

-- Handle key inputs for selecting and loading/saving
function saveLoad.keypressed(key)
    if key == "up" then
        selectedSlot = math.max(1, selectedSlot - 1)
    elseif key == "down" then
        selectedSlot = math.min(5, selectedSlot + 1)
    elseif key == "return" then
        saveLoad.saveGame(selectedSlot)
    elseif key == "l" then
        saveLoad.loadGame(selectedSlot)
    end
end

return saveLoad
