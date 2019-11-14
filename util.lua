-- Utilities! (yay?)

local CN = require("crazy_numbers")
local util = {}

-- Table clone method (Put this somewhere else when you are done plz)
-- Credit: http://lua-users.org/wiki/CopyTable
function util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
-- Credit: https://gist.github.com/hashmal/874792
function util.tprint (tbl, indent)
if not indent then indent = 0 end
for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
if type(v) == "table" then
print(formatting)
util.tprint(v, indent+1)
else
    if type(v) == "function" then
        print(formatting .. "some funciton")
    else
        print(formatting .. v)
    end
end
end
end

-- Returns the default parent object that travels from the top of the
-- screen to the bottom in a given ammount of time (Stored in speed)
function util.newParentObstacle(speed)
    local BOTTOM_Y = (display.contentHeight/CN.COL_WIDTH)
    local MIDDLE_X = (display.contentWidth/CN.COL_WIDTH)/2
    local parent = {
        name = "Parent",
        position_path = {util.newPoint(MIDDLE_X, BOTTOM_Y), util.newPoint(MIDDLE_X, 0)},
        rotation_path = {0,0},
        transition_time = {speed, speed},
        position_interpolation = easing.linear,
        rotation_interpolation = easing.linear,
        on_complete = "destroy",
        first_frame = 2,
        children = nil
    }
    return parent
end

-- Returns a Point object (x,y) pair
function util.newPoint(x_in, y_in)
    local point = {x=x_in, y=y_in}
    return point
end

-- Prints the name and nestled objects for an obstacle_data data structure
function util.printObstacleData(data, indent)
    if not data then return end
    if not indent then indent = 0 end
    local formatting = string.rep("\t", indent)

    if type(data) == "table" then
        print(formatting..data.name..":")
    elseif type(data) == "string" then
        print(formatting..data)
    end

    for i = 1, #data.objects, 1 do
        util.printObstacleData(data.objects[i], indent+1)
    end
end

-- Prints memory usage data
-- Credit: https://forums.coronalabs.com/topic/22091-guide-findingsolving-memory-leaks/
function util.printMemUsage()
    local memUsed = (collectgarbage("count")) / 1000
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1000000

    print("\n---------MEMORY USAGE INFORMATION---------")
    print("System Memory Used:", string.format("%.03f", memUsed), "Mb")
    print("Texture Memory Used:", string.format("%.03f", texUsed), "Mb")
    print("------------------------------------------\n")

    return true
end

-- returns true if table contains entry, false otherwise
function util.tableContains(tbl, item)
    if not tbl then return false end
    if not type(tbl) == "table" then return false end
    for i = 1, #tbl, 1 do
        if tbl[i] == item then return true end
    end
    return false
end

-- removes item from list. Returns true if success, false otherwise
function util.removeFromList(tbl, item)
    if not tbl then return false end
    if not type(tbl) == "table" then return false end
    for i = 1, #tbl, 1 do
        if tbl[i] == item then 
            table.remove(tbl, i)
            return true 
        end
    end
    return false
end


return util
