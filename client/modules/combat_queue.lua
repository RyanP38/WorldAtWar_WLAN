--= combat_queue.lua =--
-- Manages a queue of battles to be resolved sequentially.

local combatQueue = {}
combatQueue.queue = {}
combatQueue.currentBattle = nil

-- Add a battle to the queue
function combatQueue.addBattle(territory, attackerUnits, defenderUnits)
    table.insert(combatQueue.queue, {
        territory = territory,
        attacker = attackerUnits,
        defender = defenderUnits
    })
end

-- Start the next battle in the queue
function combatQueue.startNextBattle()
    if #combatQueue.queue > 0 then
        combatQueue.currentBattle = table.remove(combatQueue.queue, 1)
        return combatQueue.currentBattle
    else
        combatQueue.currentBattle = nil
        return nil
    end
end

-- Check if a battle is ongoing
function combatQueue.isBattleActive()
    return combatQueue.currentBattle ~= nil
end

-- Complete the current battle and move to the next one
function combatQueue.completeBattle()
    combatQueue.currentBattle = nil
    return combatQueue.startNextBattle()
end

-- Get the current battle
function combatQueue.getCurrentBattle()
    return combatQueue.currentBattle
end

return combatQueue
