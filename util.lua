-- Utilities! (yay?)

local CN = require("crazy_numbers")
local util = {}

-- Helpful numbers
local _left = -CN.COL_NUM/2
local _right = CN.COL_NUM/2
local _top = (display.contentHeight/CN.COL_WIDTH)/2
local _bottom = -(display.contentHeight/CN.COL_WIDTH)/2
local _halfSpikeWidth = CN.SPIKE_WIDTH/2
local _halfSpikeHeight = CN.SPIKE_HEIGHT/2


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
    if type(tbl2) ~= "table" then table.insert(tbl1, tbl2) end

    local start_i = #tbl1
    for i = 1, #tbl2, 1 do
        tbl1[start_i+i] = tbl2[i]
    end
end

-- deepcopies item n times
function util.list(item, n)
	local result = {}
	for i = 1, n, 1 do
		table.insert(result, util.deepcopy(item))
	end
	return result
end

-- ******************************** LEVEL BUILDING UTILITIES ***************************************

-- Returns the default parent object that travels from the top of the
-- screen to the bottom in a given ammount of time (Stored in speed)
function util.newParentObstacle(speed, name, topExtend, bottomExtend)
	if not topExtend then topExtend = 0 end
	if not bottomExtend then bottomExtend = 0 end
	if not name then name = "Parent" end
	local heightBlocks = (display.contentHeight/CN.COL_WIDTH)
	local travelDist = heightBlocks + topExtend + bottomExtend
	local adjustSpeed = speed*travelDist/heightBlocks

    local BOTTOM_Y = (display.contentHeight/CN.COL_WIDTH)
    local MIDDLE_X = (display.contentWidth/CN.COL_WIDTH)/2
    local parent = {
        type = "null",
        name = name,
        position_path = {util.newPoint(MIDDLE_X, BOTTOM_Y+bottomExtend), util.newPoint(MIDDLE_X, 0-topExtend)},
        rotation_path = {0,0},
        transition_time = {adjustSpeed, adjustSpeed},
        position_interpolation = easing.linear,
        rotation_interpolation = easing.linear,
        on_complete = "destroy",
        first_frame = 2,
        children = {}
    }
    return parent
end

-- THE FOLLOWING LEVEL BUILDING UTILITIES ALL RETURN A TABLE OF OBJECTS (NULL OR DISPLAY)

-- Note that color is stored as a list and is used as follows: myText:setFillColor( color[1], color[2], color[3]) 
function util.newText(x, y, displayText, font, fontSize, color)
    if not font then font = native.systemFont end
    if not color then color = {0,0,0} end
    local text = {}
    text.type = "text" -- Special text attribute
    text.font = font -- Special text attribute
    text.fontSize = CN.COL_WIDTH * fontSize -- Special text attribute
    text.color = color -- Special text attribute
    text.x = x
    text.y = y
    text.text = displayText
    text.rotation = 0
    return text
end

function util.newCoin(x,y)
	local coin = {}
	coin.type = "coin"
	coin.x = x
	coin.y = y
	coin.rotation = 0
	return coin
end

function util.newBlackSquare(x, y, rot)
    local square = {}
    square.type = "black_square"
    square.x = x
    square.y = y
    square.rotation = rot
    return square
end

function util.newSpikePoint(x, y, rot)
    local spike = {}
    spike.type = "spike"
    spike.x = x
    spike.y = y
    spike.rotation = rot
    return spike
end

function util.newSpike(x,y, isVertical)
    local topSpike
    local block
    local bottomSpike

    if isVertical then
    	topSpike = util.newSpikePoint(x, y-1, 0)
   		block = util.newBlackSquare(x, y, 0)
    	bottomSpike = util.newSpikePoint(x, y+1, 180)
    else
    	topSpike = util.newSpikePoint(-1+x, y, 270)
    	block = util.newBlackSquare(x, y, 0)
    	bottomSpike = util.newSpikePoint(x+1, y, 90)
    end

    return {topSpike, block, bottomSpike}
end

function util.newObjectList(n, object_type)
    local result = {}
    for i = 1, n, 1 do
        if(object_type == "spike") then

        end
    end
    return result
end

function util.newSpikeList(n, isVertical)
	local result = {}
	for i = 1, n, 1 do
		table.insert(result, util.newSpike(0,0,isVertical))
	end
	return result
end

-- Wraps list of objects around a path (and loops)
-- number of objects and number of path vertices must be equal
-- Used to create line, square, polygon, and other looping fun things
function util.wrapLoopPath(nullModel, objectList)
	local result = {}
	for i = 1, #nullModel.position_path, 1 do
		local thisObject = util.deepcopy(nullModel)
		if objectList[i] then
			util.tableExtend(thisObject.children, objectList[i])
			thisObject.first_frame = i
			table.insert(result, thisObject)
		end
	end
	return result
end

-- Simple line from x to y, loops endlessly
function util.newLineModel(startPoint, endPoint, num_objects, period)
    local nullModel = {}
    nullModel.type = "null"
    nullModel.name = "LineModel"
    nullModel.position_interpolation = easing.linear
    nullModel.rotation_interpolation = easing.linear
    nullModel.on_complete = "loop"
    nullModel.children = {}

    -- Set position_path, rotation_path, transition_time
    local position_path = {}
    local rotation_path = {}
    local transition_time = {}
    for i = 1, (num_objects+1), 1 do
        local dx = ((endPoint.x-startPoint.x)/num_objects) * (i-1)
        local dy = ((endPoint.y-startPoint.y)/num_objects) * (i-1)
        local x = dx + startPoint.x
        local y = dy + startPoint.y
        table.insert(position_path, util.newPoint(x, y))
        table.insert(rotation_path, 0)
        if i == 1 then
            table.insert(transition_time, 0)
        else
            table.insert(transition_time, period/num_objects)
        end
    end
    nullModel.position_path = position_path
    nullModel.rotation_path = rotation_path
    nullModel.transition_time = transition_time

    return nullModel
end


-- Creates a new square (4 vertices) with 4 spikes
function util.new4SquareModel(center, edge_size, period)
	local nullModel = {}
    nullModel.type = "null"
    nullModel.name = "4SquareModel"
    nullModel.position_interpolation = easing.linear
    nullModel.rotation_interpolation = easing.linear
    nullModel.on_complete = "loop"
    nullModel.children = {}

    -- Set position_path, rotation_path, transition_time
    local position_path = {}
    local rotation_path = {}
    local transition_time = {}
    local max = edge_size/2
    for i = 1, 4, 1 do
    	local xSign = 1
    	local ySign = 1
    	if (i == 1) or (i == 4) then
    		xSign = -1
    	end
    	if (i == 3) or (i == 4) then
    		ySign = -1
    	end

    	table.insert(position_path, util.newPoint(center.x + xSign*max, center.y + ySign*max))
    	table.insert(transition_time, period/4)
    	table.insert(rotation_path, 0)
    end
    nullModel.position_path = position_path
    nullModel.rotation_path = rotation_path
    nullModel.transition_time = transition_time

    return nullModel
end

-- Duplicates object 1-#Nodes in line model and animates as line
-- Returns list of nulls
function util.wrapToLine(lineModel, object)
	local n = #lineModel.position_path - 1
	local objectList = util.list(object, n)
	local combine = util.wrapLoopPath(lineModel, objectList)
	return combine
end

-- Takes all children from obstacle2 and adds them to obstacle1
function util.mergeObstacle(ob1, ob2)
    util.tableExtend(ob1.children, ob2.children)
end

------------------------------ FULLY FORMED OBSTACLES --------------------------
-- All obstacles returned from these methods must be game ready
-- This means there must be no clipping/dissapearing elements
-- Careful assuming spike size is 3*COL_WIDTH -> do something in CN to fix that


-- Fills a horizontal line across the screen with object_type except for at ignore_locations
-- specified in object_locations (1 object at the center of every column division)
function util.fillHorizontalLine_(speed, ignore_locations, object_type)
    local obstacle = util.newParentObstacle(speed, "fillHorizontalLine_", 1.5, 1.5) -- This 1.5 will change depending on object_type
    for i = 1, CN.COL_NUM, 1 do
        if not util.tableContains(ignore_locations, i) then
            print("adding "..i)
            local x = (i-1)+.5
            x = x - CN.COL_NUM/2 -- Because center line is 0
            if object_type == "spike" then
                object = util.newSpike(x, 0, true)
            elseif object_type == "coin" then
                object = {util.newCoin(x, 0)}
            end
            util.tableExtend(obstacle.children, object)
        end
    end
    return obstacle
end

function util.stillText_(speed, x, y, displayText, font, fontSize, color)
    local obstacle = util.newParentObstacle(speed, "stillText_", fontSize/2, fontSize/2)
    obstacle.children = {util.newText(x, y, displayText, font, fontSize, color)}
    return obstacle
end

-- Simple stationary line with different objects (Spike, square, coin, etc...)
function util.stillLine_(speed, num_objects, ignore, object_type)
    local obstacle = util.newParentObstacle(speed, "stillLine_", 1.5, 1.5) -- This 1.5 will change depending on object_type
    local width = CN.COL_NUM/(num_objects+1)
    local center = CN.COL_NUM/2
    for i = 1, num_objects, 1 do
        if not util.tableContains(ignore, i) then
            local x = (i*width)-center
            local object
            if object_type == "spike" then
                object = util.newSpike(x, 0, true)
            elseif object_type == "coin" then
                object = {util.newCoin(x, 0)}
            end
            util.tableExtend(obstacle.children, object)
        end
    end
    return obstacle
end

-- Simple stationary spike line (No animation)
-- ignore -> if a number is contained in ignore, no spike will be added at that index
function util.stillSpikeLine_(speed, num_spikes, ignore)
	local obstacle = util.newParentObstacle(speed, "stillSpikeLine_", 1.5, 1.5)
	local width = CN.COL_NUM/(num_spikes+1)
	local center = CN.COL_NUM/2
	for i = 1, num_spikes, 1 do
		if not util.tableContains(ignore, i) then
			local x = (i*width)-center
			local spike = util.newSpike(x,0,true)
			util.tableExtend(obstacle.children, spike)
		end
	end
	return obstacle
end

-- Two squares animated along a line
function util.smallSquareLine_(speed, squareSize)
	local obstacle = util.newParentObstacle(speed, "smallSquareLine_", _halfSpikeHeight+(squareSize/2), _halfSpikeHeight+(squareSize/2))
	local s = util.newPoint(2*_left, 0)
	local e = util.newPoint(2*_right, 0)
	local lineModel = util.newLineModel(s, e, 2, 8000)
	local squareModel = util.new4SquareModel(util.newPoint(0,0), squareSize, 8000)
	local square = util.wrapLoopPath(squareModel, util.newSpikeList(4, true))
	util.tableExtend(obstacle.children, util.wrapToLine(lineModel, square))
	
	return obstacle
end

-- Simple 4 square with no special movement
function util.still4Square_(speed, squareSize, period)
	local obstacle = util.newParentObstacle(speed, "still4Square_", _halfSpikeHeight+(squareSize/2), _halfSpikeHeight+(squareSize/2))
    local squareModel = util.new4SquareModel(util.newPoint(0,0), squareSize, period)
    local squares = util.wrapLoopPath(squareModel, util.newSpikeList(4, true))
    util.tableExtend(obstacle.children, squares)
    return obstacle
end

function util.coinCircle_(speed, radius, num_coins)
	local obstacle = util.newParentObstacle(speed, "coinCircle_", .5+radius, .5+radius)
	local coins = {}
	local angle = 2*math.pi/num_coins
	for i = 1, num_coins, 1 do
		table.insert(coins, util.newCoin(radius*math.cos(i*angle),radius*math.sin(i*angle)))
	end
	util.tableExtend(obstacle.children, coins)
	return obstacle
end


-- Simple animated line of any type
-- ignore -> if a number is contained in ignore, no spike will be added at that index
function util.simpleLine_(speed, startPoint, endPoint, num_objects, period, ignore, object_type)
    if not ignore then ignore = {} end
    local obstacle = util.newParentObstacle(speed, "simpleLine_", _halfSpikeHeight+(startPoint.y), _halfSpikeHeight+(endPoint.y))
    local lineModel = util.newLineModel(startPoint, endPoint, num_objects, period)
    local wrapList = util.newSpikeList(num_objects, true)
    for i = 1, #ignore, 1 do
        wrapList[ignore[i]] = nil
    end
    local line = util.wrapLoopPath(lineModel, wrapList)
    util.tableExtend(obstacle.children, line)
    return obstacle
end

-- Simple animated spike line
-- ignore -> if a number is contained in ignore, no spike will be added at that index
function util.spikeLine_(speed, startPoint, endPoint, num_spikes, period, ignore)
	if not ignore then ignore = {} end
	local obstacle = util.newParentObstacle(speed, "spikeLine_", _halfSpikeHeight+(startPoint.y), _halfSpikeHeight+(endPoint.y))
	local lineModel = util.newLineModel(startPoint, endPoint, num_spikes, period)
	local wrapList = util.newSpikeList(num_spikes, true)
	for i = 1, #ignore, 1 do
		wrapList[ignore[i]] = nil
	end
	local line = util.wrapLoopPath(lineModel, wrapList)
	util.tableExtend(obstacle.children, line)
	return obstacle
end

return util