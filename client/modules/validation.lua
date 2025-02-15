--= validation.lua =--
-- This file contains validation functions for actions in the WLAN Strategy Game.

-- Validate Unit Movement
function validateMove(playerId, from, to)
    local player = findPlayerById(playerId)
    local source = getTerritory(from)
    local destination = getTerritory(to)

    if not source then
        return false, "Source territory does not exist."
    end
    if not destination then
        return false, "Destination territory does not exist."
    end
    if source.owner ~= player.name then
        return false, "Invalid move: source not owned by player."
    end
    if not isAdjacent(from, to) then
        return false, "Invalid move: territories are not adjacent."
    end

    return true, "Valid move."
end

-- Validate Purchases
function validatePurchase(playerId, purchase)
    local player = findPlayerById(playerId)
    if not player then
        return false, "Player does not exist."
    end
    if player.resources < purchase.cost then
        return false, "Insufficient resources."
    end
    if purchase.quantity and purchase.quantity > 10 then -- Example limit
        return false, "Cannot purchase more than 10 units at a time."
    end

    return true, "Valid purchase."
end

-- Validate Unit Placement
function validatePlacement(playerId, territoryName, unit)
    local player = findPlayerById(playerId)
    local territory = getTerritory(territoryName)

    if not player then
        return false, "Player does not exist."
    end
    if not territory then
        return false, "Territory does not exist."
    end
    if territory.owner ~= player.name then
        return false, "Cannot place units in a territory not owned by the player."
    end
    if unit.type == "naval" and not territory.isSeaZone then
        return false, "Cannot place naval units in non-sea territories."
    end

    return true, "Valid placement."
end

-- Adjacency Check
function isAdjacent(from, to)
    -- Example adjacency logic (to be replaced with real data)
    local adjacencyList = {
        TerritoryA = { "TerritoryB", "TerritoryC" },
        TerritoryB = { "TerritoryA", "TerritoryD" },
        TerritoryC = { "TerritoryA" },
    }

    local neighbors = adjacencyList[from]
    if neighbors then
        for _, neighbor in ipairs(neighbors) do
            if neighbor == to then
                return true
            end
        end
    end

    return false
end

return {
    validateMove = validateMove,
    validatePurchase = validatePurchase,
    validatePlacement = validatePlacement,
    isAdjacent = isAdjacent
}
