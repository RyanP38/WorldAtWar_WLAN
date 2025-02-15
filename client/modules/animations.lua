--= animations.lua =--
-- This file contains animation functions for the WLAN Strategy Game.

-- Animate Unit Movement
function animateUnitMovement(unit, path)
    local duration = 1 * #path -- 1 second per territory
    local elapsedTime = 0
    local currentSegment = 1

    function unit:update(dt)
        if currentSegment < #path then
            elapsedTime = elapsedTime + dt
            local progress = elapsedTime / duration

            if progress >= 1 then
                currentSegment = currentSegment + 1
                elapsedTime = 0
            else
                unit.x, unit.y = interpolate(path[currentSegment], path[currentSegment + 1], progress)
            end
        end
    end
end

-- Animate Unit Placement
function animatePlacement(unit)
    unit.alpha = 0

    function unit:update(dt)
        if unit.alpha < 1 then
            unit.alpha = unit.alpha + dt
        end
    end
end

-- Interpolation Function
function interpolate(point1, point2, t)
    return {
        x = point1.x + (point2.x - point1.x) * t,
        y = point1.y + (point2.y - point1.y) * t
    }
end

-- Example Usage
--[[
local unit = {
    x = 0,
    y = 0,
    alpha = 1,
    update = function(dt) end
}

local path = {
    { x = 100, y = 100 },
    { x = 200, y = 200 },
    { x = 300, y = 300 }
}

animateUnitMovement(unit, path)
]]
