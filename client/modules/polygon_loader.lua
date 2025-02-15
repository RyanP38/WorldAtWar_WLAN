--= polygon_loader.lua =--
-- This module loads and renders binary polygon data for territories, including
-- dynamic coloring based on ownership and displaying IPC value sprites.

local polygonLoader = {}
local gameState = require("game_state") -- Ensure game state is accessible for ownership
local ipcSprites = {}

-- Load IPC sprites once
function polygonLoader.loadIPCSprites()
    for i = 1, 10 do  -- Assuming IPC values range from 1 to 10
        ipcSprites[i] = love.graphics.newImage("assets/ipc/" .. i .. ".png")
    end
end

-- Function to read binary polygon data from a file
function polygonLoader.loadPolygon(territoryName)
    local fileData = love.filesystem.read("polygons/" .. territoryName .. ".bin")
    if not fileData then
        print("Error: Could not load polygon data for " .. territoryName)
        return nil
    end

    local points = {}
    local index = 1
    local numPoints = string.unpack("I", fileData, index)  -- Read number of points
    index = index + 4
    
    for i = 1, numPoints do
        local x, y = string.unpack("ff", fileData, index)  -- Read float x, y coordinates
        index = index + 8
        table.insert(points, {x = x, y = y})
    end
    
    return points
end

-- Function to determine territory color based on current owner
function polygonLoader.getTerritoryColor(territoryName)
    local territory = gameState.gameState.territories[territoryName]
    if not territory then return {1, 1, 1, 1} end -- Default to white if no data
    
    local owner = territory.current_owner
    local nationColors = {
        ["Germany"] = {0.8, 0, 0, 1},  -- Red
        ["Britain"] = {0, 0.8, 0, 1},  -- Green
        ["Japan"] = {1, 1, 0, 1},      -- Yellow
        ["USA"] = {0, 0, 1, 1},        -- Blue
        ["Neutral"] = {0.5, 0.5, 0.5, 1} -- Gray
    }
    
    return nationColors[owner] or {1, 1, 1, 1} -- Default to white if unknown owner
end

-- Function to draw a territory polygon with ownership color and IPC sprite overlay
function polygonLoader.drawPolygon(territoryName, points)
    if not points or #points < 3 then return end  -- Must have at least 3 points
    
    -- Get territory color based on owner
    local color = polygonLoader.getTerritoryColor(territoryName)
    love.graphics.setColor(color)
    
    -- Draw filled polygon
    local vertices = {}
    for _, point in ipairs(points) do
        table.insert(vertices, point.x)
        table.insert(vertices, point.y)
    end
    love.graphics.polygon("fill", vertices)
    
    -- Draw IPC sprite at polygon center
    local centerX, centerY = 0, 0
    for _, point in ipairs(points) do
        centerX = centerX + point.x
        centerY = centerY + point.y
    end
    centerX = centerX / #points
    centerY = centerY / #points
    
    local territory = gameState.gameState.territories[territoryName]
    if territory and territory.IPC_value then
        local ipcValue = math.min(10, math.max(1, territory.IPC_value)) -- Clamp value between 1 and 10
        if ipcSprites[ipcValue] then
            love.graphics.setColor(1, 1, 1, 1) -- Reset to white for sprite rendering
            love.graphics.draw(ipcSprites[ipcValue], centerX - 10, centerY - 10, 0, 1, 1)
        end
    end
end

return polygonLoader
