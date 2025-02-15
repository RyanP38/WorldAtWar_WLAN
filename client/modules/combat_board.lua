--= combat_board.lua =--
-- Handles the combat GUI and integrates with combat_queue.lua

local combatBoard = {}
local combatQueue = require("combat_queue")

-- Combat state
combatBoard.activeBattle = nil

-- Initialize the combat board when a battle starts
function combatBoard.startBattle()
    combatBoard.activeBattle = combatQueue.startNextBattle()
end

-- Draw the combat board
function combatBoard.draw()
    if not combatBoard.activeBattle then return end
    
    love.graphics.print("Combat in: " .. combatBoard.activeBattle.territory, 10, 10)
    
    -- Draw attacker units
    love.graphics.print("Attacker Units:", 10, 40)
    local y = 70
    for i, unit in ipairs(combatBoard.activeBattle.attacker) do
        love.graphics.print(unit.name .. " x" .. unit.quantity, 10, y)
        love.graphics.rectangle("line", 5, y - 5, 150, 20) -- Clickable area for removal
        y = y + 20
    end
    
    -- Draw defender units
    love.graphics.print("Defender Units:", 200, 40)
    y = 70
    for i, unit in ipairs(combatBoard.activeBattle.defender) do
        love.graphics.print(unit.name .. " x" .. unit.quantity, 200, y)
        love.graphics.rectangle("line", 195, y - 5, 150, 20) -- Clickable area for removal
        y = y + 20
    end
    
    -- Draw retreat buttons
    love.graphics.rectangle("line", 10, 300, 100, 30)
    love.graphics.print("Retreat Attacker", 15, 310)
    
    love.graphics.rectangle("line", 200, 300, 100, 30)
    love.graphics.print("Retreat Defender", 205, 310)
    
    -- Draw confirmation button
    love.graphics.rectangle("line", 400, 300, 100, 30)
    love.graphics.print("Confirm Battle End", 405, 310)
end

-- Handle mouse clicks to remove units or retreat
function combatBoard.mousepressed(x, y, button)
    if not combatBoard.activeBattle then return end
    
    -- Check for unit removal (attacker side)
    local unitY = 70
    for i, unit in ipairs(combatBoard.activeBattle.attacker) do
        if x >= 5 and x <= 155 and y >= unitY - 5 and y <= unitY + 15 then
            table.remove(combatBoard.activeBattle.attacker, i)
            return
        end
        unitY = unitY + 20
    end
    
    -- Check for unit removal (defender side)
    unitY = 70
    for i, unit in ipairs(combatBoard.activeBattle.defender) do
        if x >= 195 and x <= 345 and y >= unitY - 5 and y <= unitY + 15 then
            table.remove(combatBoard.activeBattle.defender, i)
            return
        end
        unitY = unitY + 20
    end
    
    -- Check for retreat actions
    if x >= 10 and x <= 110 and y >= 300 and y <= 330 then
        combatBoard.retreat("attacker")
    elseif x >= 200 and x <= 300 and y >= 300 and y <= 330 then
        combatBoard.retreat("defender")
    elseif x >= 400 and x <= 500 and y >= 300 and y <= 330 then
        combatBoard.completeBattle()
    end
end

-- Handle retreat logic
function combatBoard.retreat(side)
    if side == "attacker" then
        combatBoard.activeBattle.attacker = {} -- Clear attacking units to retreat
    elseif side == "defender" then
        combatBoard.activeBattle.defender = {} -- Clear defending units (if submarines retreat)
    end
end

-- Complete the current battle and move to the next one
function combatBoard.completeBattle()
    combatBoard.activeBattle = combatQueue.completeBattle()
end

return combatBoard
