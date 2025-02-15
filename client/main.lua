--= main.lua =--
-- Entry point for the WLAN Strategy Game.

-- Modules
local gameState = require("game_state")
local animations = require("animations")
local validation = require("validation")

-- Love2D Callbacks
function love.load()
    -- Load game state if available
    gameState.loadGameState()
    print("Game loaded. Current turn:", gameState.gameState.turnOrder[gameState.gameState.currentTurn])
end

function love.update(dt)
    -- Update animations
    for _, territory in pairs(gameState.gameState.territories) do
        for _, unit in ipairs(territory.units or {}) do
            if unit.update then
                unit:update(dt)
            end
        end
    end
end

function love.draw()
    -- Draw territories and units (placeholder example)
    for name, territory in pairs(gameState.gameState.territories) do
        love.graphics.print(name, 100, 50) -- Replace with actual map rendering
        if territory.units then
            for _, unit in ipairs(territory.units) do
                love.graphics.circle("fill", unit.x or 0, unit.y or 0, 5) -- Placeholder for unit rendering
            end
        end
    end
end

function love.keypressed(key)
    if key == "n" then
        -- Move to the next turn
        gameState.nextTurn()
        print("Turn changed to:", gameState.gameState.turnOrder[gameState.gameState.currentTurn])
    elseif key == "s" then
        -- Save the game state
        gameState.saveGameState()
    end
end

-- Example Action Integration
function exampleMove()
    local isValid, message = validation.validateMove(1, "TerritoryA", "TerritoryB")
    if isValid then
        print("Move successful!")
        -- Apply the move (placeholder)
        gameState.gameState.territories["TerritoryB"].units = gameState.gameState.territories["TerritoryA"].units
        gameState.gameState.territories["TerritoryA"].units = {}
    else
        print("Move failed:", message)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        exampleMove() -- Trigger a move action as an example
    end
end
