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

-- Clones a table at the first level
function util.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for i = 1, #orig, 1 do
            copy[i] = orig[i]
        end
    else
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
    print("removeFromList() ERROR: item not found in list")
    return false
end

-- Extends adds the elements of tbl2 to tbl1
function util.tableExtend(tbl1, tbl2)
    if not tbl1 then tbl1 = {} end
    if not tbl2 then return end

    for i = 1, #tbl2, 1 do
        tbl1[#tbl1+i] = tbl2[i]
    end
end

-- ******************************** LEVEL BUILDING UTILITIES ***************************************

-- Returns the default parent object that travels from the top of the
-- screen to the bottom in a given ammount of time (Stored in speed)
function util.newParentObstacle(speed)
    local BOTTOM_Y = (display.contentHeight/CN.COL_WIDTH)
    local MIDDLE_X = (display.contentWidth/CN.COL_WIDTH)/2
    local parent = {
        type = "null",
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

-- THE FOLLOWING LEVEL BUILDING UTILITIES ALL RETURN A TABLE OF OBJECTS (NULL OR DISPLAY)

function util.newHorizontalSpike(x,y)
    local topSpike = {}
    local block = {}
    local bottomSpike = {}

    topSpike.type = "spike"
    topSpike.x = -1+x
    topSpike.y = 0+y
    topSpike.rotation = 270
    block.type = "black_square"
    block.x = 0+x
    block.y = 0+y
    block.rotation = 0
    bottomSpike.type = "spike"
    bottomSpike.x = 1+x
    bottomSpike.y = 0+y
    bottomSpike.rotation = 90

    return {topSpike, block, bottomSpike}
end

function util.newVerticalSpike(x,y)
    local topSpike = {}
    local block = {}
    local bottomSpike = {}

    topSpike.type = "spike"
    topSpike.x = 0+x
    topSpike.y = -1+y
    topSpike.rotation = 0
    block.type = "black_square"
    block.x = 0+x
    block.y = 0+y
    block.rotation = 0
    bottomSpike.type = "spike"
    bottomSpike.x = 0+x
    bottomSpike.y = 1+y
    bottomSpike.rotation = 180

    return {topSpike, block, bottomSpike}
end

-- Simple spike line from x to y, loops endlessly
function util.newSpikeLine(start_x, start_y, end_x, end_y, num_spikes, period, isVertical)
    local lineNull = {}
    lineNull.type = "null"
    lineNull.name = "SpikeLineNull_"
    lineNull.position_interpolation = easing.linear
    lineNull.rotation_interpolation = easing.linear
    lineNull.on_complete = "loop"
    lineNull.children = {}
    if isVertical then
        util.tableExtend(lineNull.children, util.newVerticalSpike(0,0))
    else
        util.tableExtend(lineNull.children, util.newHorizontalSpike(0,0))
    end

    -- Set position_path, rotation_path, transition_time
    local position_path = {}
    local rotation_path = {}
    local transition_time = {}
    for i = 1, num_spikes+1, 1 do
        local dx = (end_x-start_x) * (i-1)
        local dy = (end_y-start_y) * (i-1)
        local x = dx + start_x
        local y = dy + start_y
        table.insert(position_path, util.newPoint(x, y))
        table.insert(rotation_path, 0)
        if i <= num_spikes then
            table.insert(transition_time, period/num_spikes)
        else
            table.insert(transition_time, 0)
        end
    end

    -- Assemble the list!
    local objects = {}
    for i = 1, num_spikes, 1 do
        local thisObject = util.deepcopy(lineNull)
        thisObject.first_frame = i
        table.insert(objects, thisObject)
    end

    return objects
end

return util
