--= WLAN Strategy Game: Combined Code =--
-- This is a consolidated version of the game's code, implementing core functionality discussed so far.

-- Dependencies
local json = require("json") -- JSON library for encoding/decoding.

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

-- Action Queue
local actionQueue = {}

function addAction(playerId, actionType, details)
    table.insert(actionQueue, { playerId = playerId, actionType = actionType, details = details })
end

function processActions()
    for _, action in ipairs(actionQueue) do
        local isValid, result = validateAction(action)
        if isValid then
            applyAction(action)
        else
            print("Invalid action:", result)
        end
    end
    actionQueue = {} -- Clear queue after processing
end

-- Save Game State
function saveGameState()
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

-- Animations
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

function animatePlacement(unit)
    unit.alpha = 0
    function unit:update(dt)
        if unit.alpha < 1 then
            unit.alpha = unit.alpha + dt
        end
    end
end

-- Validation
function validateMove(playerId, from, to)
    local player = findPlayerById(playerId)
    local source = gameState.territories[from]
    local destination = gameState.territories[to]

    if source.owner ~= player.name then
        return false, "Invalid move: source not owned by player."
    end
    if not isAdjacent(from, to) then
        return false, "Invalid move: territories are not adjacent."
    end

    return true
end

function validatePurchase(playerId, purchase)
    local player = findPlayerById(playerId)
    if player.resources < purchase.cost then
        return false, "Insufficient resources."
    end
    return true
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

function isAdjacent(from, to)
    -- Mock adjacency check
    return true -- Assume all territories are adjacent for now
end

function interpolate(point1, point2, t)
    return point1.x + (point2.x - point1.x) * t, point1.y + (point2.y - point1.y) * t
end

-- Example Usage
addAction(1, "move", { unitId = 42, path = {"TerritoryA", "TerritoryB"} })
processActions()
nextTurn()
saveGameState()
loadGameState()

-- Server-Side Logic (Node.js Example)
const WebSocket = require('ws');
const crypto = require('crypto');
const fs = require('fs');

const wss = new WebSocket.Server({ port: 8080 });
const sessions = {}; // Store game sessions

function createRoom() {
    const roomCode = crypto.randomBytes(3).toString('hex').toUpperCase();
    sessions[roomCode] = { players: [], spectators: [], gameState: {} };
    return roomCode;
}

function saveSessionState(roomCode) {
    const session = sessions[roomCode];
    if (session) {
        fs.writeFileSync(`session_${roomCode}.json`, JSON.stringify(session.gameState));
        console.log(`Game state for room ${roomCode} saved.`);
    }
}

wss.on('connection', (ws) => {
    ws.on('message', (message) => {
        const data = JSON.parse(message);

        if (data.type === 'join_room') {
            const room = sessions[data.roomCode];
            if (!room) {
                ws.send(JSON.stringify({ type: 'error', message: 'Invalid room code' }));
                return;
            }

            const player = { id: data.playerId, isSpectator: data.isSpectator || false };
            if (player.isSpectator) {
                room.spectators.push(player);
            } else {
                room.players.push(player);
            }

            ws.roomCode = data.roomCode;
            ws.playerId = data.playerId;
            ws.isSpectator = player.isSpectator;
            ws.send(JSON.stringify({ type: 'join_success', roomCode: data.roomCode }));
        }
    });

    ws.on('close', () => {
        if (ws.roomCode && sessions[ws.roomCode]) {
            console.log(`Player ${ws.playerId} disconnected from room ${ws.roomCode}`);
        }
    });
});

console.log('WebSocket server running on ws://localhost:8080');
