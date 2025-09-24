-- main.lua
-- JSON polygon loader with pan/zoom support, fullscreen startup, centered fit

local json = require("dkjson")
local bootstrap = require("bootstrap")

--////////// utils
local function parse_number_list(str)
    local coords = {}
    if type(str) ~= "string" then return coords end
    for tok in tostring(str):gmatch("[-+]?%d*%.?%d+") do
        local n = tonumber(tok)
        if n ~= nil then coords[#coords+1] = n end
    end
    return coords
end

local function validate_coords(coords)
    if type(coords) ~= "table" then return false, "coords not a table" end
    if (#coords % 2) ~= 0 then return false, "odd coord count" end
    if #coords < 6 then return false, "need at least 3 points" end
    for i = 1, #coords do
        if type(coords[i]) ~= "number" then
            return false, ("non-number at %d: %s"):format(i, tostring(coords[i]))
        end
    end
    return true
end

local unpack = table.unpack or unpack

local function triangulate_safe(coords, territory, piece_label)
    local ok, verr = validate_coords(coords)
    if not ok then
        print(("[triangulate] %s/%s: invalid coords -> %s"):format(territory or "?", piece_label or "?", verr))
        return {}
    end
    local ok2, triangles = pcall(love.math.triangulate, unpack(coords))
    if not ok2 then
        print(("[triangulate] %s/%s: triangulate error -> %s"):format(territory or "?", piece_label or "?", tostring(triangles)))
        return {}
    end
    return triangles or {}
end

--////////// JSON loader
local function loadJson(file, starting_position, return_val_if_null)
    local file_content, err = love.filesystem.read(file)
    if not file_content then
        print("Error: Failed to read file - " .. tostring(file) .. " (" .. tostring(err) .. ")")
        return nil, "Failed to read file"
    end
    local content, _, decode_err = json.decode(file_content, starting_position, return_val_if_null)
    if decode_err then
        print("JSON Decode Error: " .. tostring(decode_err))
        return nil, "JSON decode failed"
    end
    return content
end

--////////// map data
local map = {
    width = 3149,
    height = 2203,
    territories = {}
}

local area_template = {
    owner = nil,
    color = nil,
    color_ID = nil,
    IPC_value = nil,
    polygon_data = {},
    outlines = {},
    adjacency_data = {},
    units = {}
}

local function load_territory_polygons(file_path)
    local obj = loadJson(file_path)
    if not obj or not obj.polygonData then
        print("Error: Missing `polygonData` in JSON file")
        return
    end
    for territory, data in pairs(obj.polygonData) do
        local territory_data = bootstrap.deepcopy(area_template)
        map.territories[territory] = territory_data
        local triangulated_shapes = {}
        local outlines = {}

        if type(data) == "table" then
            if type(data[1]) == "string" then
                for idx, coordString in ipairs(data) do
                    local coords = parse_number_list(coordString)
                    if #coords > 0 then outlines[#outlines+1] = coords end
                    local tris = triangulate_safe(coords, territory, ("piece%s"):format(idx))
                    for _, tri in ipairs(tris) do triangulated_shapes[#triangulated_shapes+1] = tri end
                end
            else
                for subkey, subtable in pairs(data) do
                    if type(subtable) == "table" then
                        if type(subtable[1]) == "string" then
                            for idx, coordString in ipairs(subtable) do
                                local coords = parse_number_list(coordString)
                                if #coords > 0 then outlines[#outlines+1] = coords end
                                local tris = triangulate_safe(coords, territory, tostring(subkey).."#"..idx)
                                for _, tri in ipairs(tris) do triangulated_shapes[#triangulated_shapes+1] = tri end
                            end
                        else
                            for idx, maybeStr in pairs(subtable) do
                                if type(maybeStr) == "string" then
                                    local coords = parse_number_list(maybeStr)
                                    if #coords > 0 then outlines[#outlines+1] = coords end
                                    local tris = triangulate_safe(coords, territory, tostring(subkey).."#"..tostring(idx))
                                    for _, tri in ipairs(tris) do triangulated_shapes[#triangulated_shapes+1] = tri end
                                end
                            end
                        end
                    end
                end
            end
        end

        territory_data.polygon_data = triangulated_shapes
        territory_data.outlines = outlines
    end
end

--////////// Pan/Zoom state
local camX, camY = 0, 0
local scale = 1
local zoomSpeed = 0.27
local minZoom, maxZoom = 0.5, 4
local dragging = false
local lastMouseX, lastMouseY = 0, 0

--////////// LÖVE setup
function love.conf(t)
    t.window.fullscreen = true
    t.window.resizable = true
    t.console = true
    t.modules.joystick = false
    t.modules.physics = false
end

function love.load()
    load_territory_polygons("territories.json")

    -- Fit to screen on startup
    local ww, wh = love.graphics.getDimensions()
    local sx = ww / map.width
    local sy = wh / map.height
    scale = math.min(sx, sy)
    camX = (ww - map.width * scale) * 0.5
    camY = (wh - map.height * scale) * 0.5

    bootstrap.tprint(map.territories)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        dragging = true
        lastMouseX, lastMouseY = x, y
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then dragging = false end
end

function love.mousemoved(x, y, dx, dy)
    if dragging then
        camX = camX + dx
        camY = camY + dy
    end
end

function love.wheelmoved(dx, dy)
    if dy ~= 0 then
        local mouseX, mouseY = love.mouse.getPosition()
        local worldX = (mouseX - camX) / scale
        local worldY = (mouseY - camY) / scale
        local newScale = scale + zoomSpeed * dy
        newScale = math.max(minZoom, math.min(maxZoom, newScale))
        camX = mouseX - worldX * newScale
        camY = mouseY - worldY * newScale
        scale = newScale
    end
end

function love.draw()
    -- map pan/scale functions
    love.graphics.push()
    love.graphics.translate(camX, camY)
    love.graphics.scale(scale)

    -- draw polygons
    local triCount = 0
    love.graphics.setColor(0.15, 0.55, 0.95, 0.9)
    for _, territory in pairs(map.territories) do
        for _, tri in ipairs(territory.polygon_data or {}) do
            love.graphics.polygon("fill", tri)
            triCount = triCount + 1
        end
    end

    -- ouline
    love.graphics.setColor(1, 1, 1, 0.35)
    for _, territory in pairs(map.territories) do
        for _, outline in ipairs(territory.outlines or {}) do
            if #outline >= 4 then
                love.graphics.line(outline)
            end
        end
    end

    love.graphics.pop()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Zoom: " .. string.format("%.2f", scale), 10, 10)
    love.graphics.print("Pan: (" .. math.floor(camX) .. ", " .. math.floor(camY) .. ")", 10, 30)
end

----- the above does a good job at combining ws1_polygons with map_test. 