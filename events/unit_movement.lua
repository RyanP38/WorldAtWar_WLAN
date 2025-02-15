--= unit_movement.lua =--
-- Handles multi-unit selection and stacking mechanics.

local unitMovement = {}
local gameState = require("game_state")

unitMovement.selectedUnits = {}
unitMovement.originTerritory = nil

-- Function to select a unit or stack of units
function unitMovement.selectUnits(territory, unitType, quantity)
    if not gameState.gameState.territories[territory] then return end
    
    local territoryUnits = gameState.gameState.territories[territory].units
    if territoryUnits and territoryUnits[unitType] and territoryUnits[unitType] >= quantity then
        unitMovement.selectedUnits = {
            type = unitType,
            quantity = quantity
        }
        unitMovement.originTerritory = territory
    end
end

-- Function to move selected units to a new territory
function unitMovement.moveUnits(targetTerritory)
    if not unitMovement.originTerritory or not gameState.gameState.territories[targetTerritory] then return end
    
    local origin = gameState.gameState.territories[unitMovement.originTerritory]
    local destination = gameState.gameState.territories[targetTerritory]
    local unitType = unitMovement.selectedUnits.type
    local quantity = unitMovement.selectedUnits.quantity
    
    -- Ensure the move is valid (adjacency check)
    if not gameState.isTerritoryAdjacent(unitMovement.originTerritory, targetTerritory) then
        print("Invalid move: Non-adjacent territory.")
        return
    end
    
    -- Move the units
    origin.units[unitType] = origin.units[unitType] - quantity
    if not destination.units[unitType] then
        destination.units[unitType] = 0
    end
    destination.units[unitType] = destination.units[unitType] + quantity
    
    -- Clear selection after move
    unitMovement.selectedUnits = {}
    unitMovement.originTerritory = nil
end

-- Function to draw unit stack indicators
function unitMovement.drawStackIndicators()
    for territory, data in pairs(gameState.gameState.territories) do
        local x, y = data.position.x, data.position.y
        for unitType, quantity in pairs(data.units) do
            if quantity > 1 then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print(quantity, x, y)
            end
        end
    end
end

return unitMovement
