--= player_gui.lua =--
-- This file contains the implementation of the player's individual nation's GUI.

-- Modules
local gameState = require("game_state")
local validation = require("validation")

-- Nation-Specific Modules (to be loaded dynamically)
local nationGUIs = {}

-- GUI State
local guiState = {
    currentNation = nil, -- The currently displayed nation in the GUI
    nations = {}, -- List of nations the player controls
    currentTab = "unit_stats", -- Default tab
    buys = {}, -- Tracks selected purchases for all nations
    planningMap = {}, -- Tracks player-specific planning map data
    drawings = {}, -- Tracks drawings made on the planning map
    placedUnits = {}, -- Tracks units dragged and placed on the planning map
}

-- Tabs (Some tabs are shared, some vary by nation)
local tabs = {
    "unit_stats", "territory_units", "technologies", "buys_summary", "planning_notes", "history_logs"
}

-- Functions to Handle Tabs
local function drawUnitStatsTab()
    love.graphics.print(guiState.currentNation .. " Unit Stats:", 10, 10)
    -- Example nation-specific unit stats
    local nationUnits = nationGUIs[guiState.currentNation].getUnitStats()
    local y = 40
    for _, unit in ipairs(nationUnits) do
        love.graphics.print(string.format("%s: Cost $%d | Atk %d | Def %d", unit.name, unit.cost, unit.attack, unit.defense), 10, y)
        y = y + 20
    end
end

local function drawTerritoryUnitsTab()
    love.graphics.print(guiState.currentNation .. " Territory Units:", 10, 10)
    local y = 40
    for name, territory in pairs(gameState.gameState.territories) do
        if territory.owner == guiState.currentNation then
            love.graphics.print(string.format("%s: %s", name, "Units: " .. (territory.units and #territory.units or 0)), 10, y)
            y = y + 20
        end
    end
end

local function drawTechnologiesTab()
    love.graphics.print(guiState.currentNation .. " Technologies:", 10, 10)
    nationGUIs[guiState.currentNation].drawTechnologiesTab()
end

local function drawBuysSummaryTab()
    love.graphics.print(guiState.currentNation .. " Selected Buys:", 10, 10)
    local y = 40
    local totalCost = 0
    local buys = guiState.buys[guiState.currentNation] or {}
    for _, buy in ipairs(buys) do
        love.graphics.print(string.format("%s x%d ($%d)", buy.unit, buy.quantity, buy.cost), 10, y)
        totalCost = totalCost + buy.cost
        y = y + 20
    end
    love.graphics.print("Total Cost: $" .. totalCost, 10, y)
end

local function drawPlanningNotesTab()
    love.graphics.print("Planning Notes for " .. guiState.currentNation, 10, 10)
end

local function drawHistoryLogsTab()
    love.graphics.print("History/Logs for " .. guiState.currentNation, 10, 10)
end

local function drawCurrentTab()
    if guiState.currentTab == "unit_stats" then
        drawUnitStatsTab()
    elseif guiState.currentTab == "territory_units" then
        drawTerritoryUnitsTab()
    elseif guiState.currentTab == "technologies" then
        drawTechnologiesTab()
    elseif guiState.currentTab == "buys_summary" then
        drawBuysSummaryTab()
    elseif guiState.currentTab == "planning_notes" then
        drawPlanningNotesTab()
    elseif guiState.currentTab == "history_logs" then
        drawHistoryLogsTab()
    end
end

-- Tab Switching
function switchTab(direction)
    local currentIndex = 1
    for i, tab in ipairs(tabs) do
        if tab == guiState.currentTab then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex + direction
    if currentIndex < 1 then
        currentIndex = #tabs
    elseif currentIndex > #tabs then
        currentIndex = 1
    end
    guiState.currentTab = tabs[currentIndex]
end

-- Nation Switching
function switchNation(direction)
    local currentIndex = 1
    for i, nation in ipairs(guiState.nations) do
        if nation == guiState.currentNation then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex + direction
    if currentIndex < 1 then
        currentIndex = #guiState.nations
    elseif currentIndex > #guiState.nations then
        currentIndex = 1
    end
    guiState.currentNation = guiState.nations[currentIndex]
end

-- Mouse Interactions for Planning Map
function love.mousepressed(x, y, button)
    if x > 300 and x < 800 and y > 50 and y < 450 then -- Inside the planning map
        if button == 1 then
            -- Start a new drawing
            table.insert(guiState.drawings, { color = {1, 0, 0}, points = {x, y} })
        elseif button == 2 then
            -- Place a unit
            table.insert(guiState.placedUnits, { x = x, y = y, type = "infantry" })
        end
    end
end

function love.mousedragged(x, y, dx, dy)
    if #guiState.drawings > 0 then
        local currentDrawing = guiState.drawings[#guiState.drawings]
        table.insert(currentDrawing.points, x)
        table.insert(currentDrawing.points, y)
    end
end

-- Love2D Callbacks
function love.load()
    -- Simulate server assignment
    guiState.nations = { "Germany", "Japan" } -- Example nations the player controls
    guiState.currentNation = guiState.nations[1]

    -- Load nation-specific GUIs dynamically
    for _, nation in ipairs(guiState.nations) do
        local moduleName = nation:lower() .. "_gui"
        nationGUIs[nation] = require(moduleName)
    end

    print("Player's GUI loaded for nations:", table.concat(guiState.nations, ", "))
end

function love.draw()
    -- Draw the GUI header
    love.graphics.print("Player's Individual Nation GUI", 10, 10)
    love.graphics.print("Current Nation: " .. guiState.currentNation, 10, 30)
    love.graphics.print("Current Tab: " .. guiState.currentTab, 10, 50)

    -- Draw the left-side tab content
    drawCurrentTab()

    -- Draw the right-side planning map
    love.graphics.rectangle("line", 300, 50, 500, 400) -- Placeholder map boundary
end

function love.keypressed(key)
    if key == "right" then
        switchTab(1)
    elseif key == "left" then
        switchTab(-1)
    elseif key == "up" then
        switchNation(1)
    elseif key == "down" then
        switchNation(-1)
    end
end
