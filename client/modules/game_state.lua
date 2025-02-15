--= game_state.lua =--
-- This file handles game state management for the WLAN Strategy Game.

-- Game State
local gameState = {
    players = {
        { id = 1, name = "Germany", resources = 50 },
        { id = 2, name = "Britain", resources = 45 },
    },
    territories = {
        ["TerritoryA"] = { owner = "Germany", units = { infantry = 3 } },
        ["TerritoryB"] = { owner = "Britain", units = { tank = 1 } },
    },
    turnOrder = {"Germany", "Britain", "France", "Japan", "Russia", "USA", "China"},
    currentTurn = 1,
    phase = "combat_movement"
}

-- Save Game State
function saveGameState()
    local json = require("json")
    local saveData = json.encode(gameState)
    local file = love.filesystem.newFile("savegame.json", "w")
    file:write(saveData)
    file:close()
    print("Game state saved!")
end

-- Load Game State
function loadGameState()
    if love.filesystem.getInfo("savegame.json") then
        local file = love.filesystem.read("savegame.json")
        local json = require("json")
        gameState = json.decode(file)
        print("Game state loaded!")
    else
        print("No save file found.")
    end
end

-- Turn Management
function nextTurn()
    gameState.currentTurn = gameState.currentTurn + 1
    if gameState.currentTurn > #gameState.turnOrder then
        gameState.currentTurn = 1 -- Loop back to the first nation
    end
    print("Current turn:", gameState.turnOrder[gameState.currentTurn])
end

-- Helper Functions
function findPlayerById(playerId)
    for _, player in ipairs(gameState.players) do
        if player.id == playerId then
            return player
        end
    end
    return nil
end

function getTerritory(name)
    return gameState.territories[name]
end

return {
    gameState = gameState,
    saveGameState = saveGameState,
    loadGameState = loadGameState,
    nextTurn = nextTurn,
    findPlayerById = findPlayerById,
    getTerritory = getTerritory
}
