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
    if not tbl1 then return end
    if not tbl2 then return end
    if type(tbl2) ~= "table" then table.insert(tbl1, tbl2) end

    local start_i = #tbl1
    for i = 1, #tbl2, 1 do
        tbl1[start_i+i] = tbl2[i]
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
        children = {}
    }
    return parent
end

-- THE FOLLOWING LEVEL BUILDING UTILITIES ALL RETURN A TABLE OF OBJECTS (NULL OR DISPLAY)

function util.newBlackSquare(x, y, rot)
    local square = {}
    square.type = "black_square"
    square.x = x
    square.y = y
    square.rotation = rot
    return square
end

function util.newSpike(x, y, rot)
    local spike = {}
    spike.type = "spike"
    spike.x = x
    spike.y = y
    spike.rotation = rot
    return spike
end

function util.newHorizontalSpike(x,y)
    local topSpike = util.newSpike(-1+x, y, 270)
    local block = util.newBlackSquare(x, y, 0)
    local bottomSpike = util.newSpike(x+1, y, 90)
    return {topSpike, block, bottomSpike}
end

function util.newVerticalSpike(x,y)
    local topSpike = util.newSpike(x, y-1, 0)
    local block = util.newBlackSquare(x, y, 0)
    local bottomSpike = util.newSpike(x, y+1, 180)
    return {topSpike, block, bottomSpike}
end

-- Wraps list of objects around a path (and loops)
-- number of objects and number of path vertices must be equal
-- Used to create line, square, polygon, and other looping fun things
function util.wrapLoopPath(nullModel, objectList)
	local result = {}
	for i = 1, #nullModel.position_path, 1 do
		local thisObject = util.deepcopy(nullModel)
		util.tableExtend(thisObject.children, objectList[i])
		thisObject.first_frame = i
		table.insert(result, thisObject)
	end
	return result
end


-- Simple spike line from x to y, loops endlessly
function util.newSpikeLine(startPoint, endPoint , num_spikes, period, isVertical)
    local nullModel = {}
    nullModel.type = "null"
    nullModel.name = "SpikeLineNull"
    nullModel.position_interpolation = easing.linear
    nullModel.rotation_interpolation = easing.linear
    nullModel.on_complete = "loop"
    nullModel.children = {}

    -- Create objects list to wrap around path
    local objectsList = {}
    for i = 1, num_spikes, 1 do
    	if isVertical then
    		table.insert(objectsList, util.newVerticalSpike(0,0))
    	else
    		table.insert(objectsList, util.newHorizontalSpike(0,0))
    	end
    end

    -- Set position_path, rotation_path, transition_time
    local position_path = {}
    local rotation_path = {}
    local transition_time = {}
    for i = 1, (num_spikes+1), 1 do
        local dx = ((endPoint.x-startPoint.x)/num_spikes) * (i-1)
        local dy = ((endPoint.y-startPoint.y)/num_spikes) * (i-1)
        local x = dx + startPoint.x
        local y = dy + startPoint.y
        table.insert(position_path, util.newPoint(x, y))
        table.insert(rotation_path, 0)
        if i == 1 then
            table.insert(transition_time, 0)
        else
            table.insert(transition_time, period/num_spikes)
        end
    end
    nullModel.position_path = position_path
    nullModel.rotation_path = rotation_path
    nullModel.transition_time = transition_time

    -- Assemble and return the list!
    return util.wrapLoopPath(nullModel, objectsList)
end


-- Creates a new square (4 vertices) with spikes that rotate around the square
function util.newSquare(center_x, center_y, edge_size, num_spikes, period, isVertical)
	local nullModel = {}

end

return util
