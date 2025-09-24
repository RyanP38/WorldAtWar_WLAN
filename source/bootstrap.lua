-- bootstrap.lua

--- helper functions ---

local bootstrap = {}

-- the general version of deepcopy
function bootstrap.deepcopy(o, seen)
    seen = seen or {}
    if o == nil then return nil end
    if seen[o] then return seen[o] end

    local no
    if type(o) == 'table' then
        no = {}
        seen[o] = no

        for k, v in next, o, nil do
            no[bootstrap.deepcopy(k, seen)] = bootstrap.deepcopy(v, seen)
        end
        setmetatable(no, bootstrap.deepcopy(getmetatable(o), seen))
    else -- number, string, boolean, etc
        no = o
    end
    return no
end

-- the table version of deepcopy
-- function table.deepcopy(o, seen) -- (DOESN'T LIKE BOOTSTRAP)
--     seen = seen or {}
--     if o == nil then return nil end
--     if seen[o] then return seen[o] end


--     local no = {}
--     seen[o] = no
--     setmetatable(no, deepcopy(getmetatable(o), seen))

--     for k, v in next, o, nil do
--         k = (type(k) == 'table') and k:deepcopy(seen) or k
--         v = (type(v) == 'table') and v:deepcopy(seen) or v
--         no[k] = v
--     end
--     return no
-- end

-- function to get deep clone of passed table (clones tables with tables).
function bootstrap.deepClone(original)
    local copy
    if type(original) == 'table' then
       -- create an empty table
       copy = {}
       -- loop through all entries	  
       for key, value in next, original, nil do
          copy[bootstrap.deepClone(key)] = bootstrap.deepClone(value)
       end
       setmetatable(copy, bootstrap.deepClone(getmetatable(original)))
    else
       -- in case of number, string etc.
       copy = original
    end
    -- return the cloned copy
    return copy
end

-- a function to simple deep copy a table
function bootstrap.copy1(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[bootstrap.copy1(k)] = bootstrap.copy1(v) end
    return res
end

-- another function to deep copy a table
function bootstrap.copy3(obj, seen)
	-- Handle non-tables and previously-seen tables.
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end

	-- New table; mark it as seen an copy recursively.
	local s = seen or {}
	local res = {}
	s[obj] = res
	for k, v in next, obj do res[bootstrap.copy3(k, s)] = bootstrap.copy3(v, s) end
	return setmetatable(res, getmetatable(obj))
end

-- thorough deepcopy
function bootstrap.print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end

-- returns the length of the table
function bootstrap.len(table)
    local count = 0
    for _ in pairs(table) do 
       count = count + 1 
    end
    return count
end

-- returns a range
-- function bootstrap.range( from , to )
--     local function (_,last) --problem here (un-named function)
--         if last >= to then 
--             return nil
--         else
--             return last+1
--         end
--     end , nil , from-1
-- end

-- returns nested tables. 
-- To use it, do print("Table Name:", dump(table))
function bootstrap.dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. bootstrap.dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function bootstrap.tprint(tbl, indent)
    if type(tbl) ~= "table" then
        print("Error: Expected a table, got " .. type(tbl))
        return
    end
    
    indent = indent or 0
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            bootstrap.tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

return bootstrap