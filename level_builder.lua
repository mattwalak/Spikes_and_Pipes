-- Temporary file so I can draft my new level building utilities

local CN = require("crazy_numbers")
local util = require("util")

local lb = {}

-- Helpful numbers
local _left = -CN.COL_NUM/2
local _right = CN.COL_NUM/2
local _top = (display.contentHeight/CN.COL_WIDTH)/2
local _bottom = -(display.contentHeight/CN.COL_WIDTH)/2
local _halfSpikeWidth = CN.SPIKE_WIDTH/2
local _halfSpikeHeight = CN.SPIKE_HEIGHT/2

--============ HELPER FUNCTIONS: Performs various operations to assist obstacle creation ==============================================================================

-- Takes all children from obstacle2 and adds them to obstacle1
function mergeObstacle(ob1, ob2)
    util.tableExtend(ob1.children, ob2.children)
end

-- Wraps list of objects into a single stationary null centered at (0,0)
local function newCenteredNull(object_list)
	local centeredNull = {
		type = "null",
		name = "centered_null",
        position_path = {util.newPoint(0, 0), util.newPoint(0, 0)},
        rotation_path = {0,0},
        transition_time = {1000, 1000},
        position_interpolation = easing.linear,
        rotation_interpolation = easing.linear,
        on_complete = "stop",
        first_frame = 2,
        children = object_list
	}
	return centeredNull
end

-- Wrapper parent object, controls top to bottom screen movement
local function newParent(speed, name, topExtend, bottomExtend)
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

-- Duplicates object (with deep copy) and creates of list of length num_objects, leaving indicies specified in ignore as nil
local function newObjectList(num_objects, ignore, object)
	if not ignore then ignore = {} end
	local result = {}
	for i = 1, num_objects, 1 do
		if util.tableContains(ignore, i) then
			result[i] = nil
		else
			result[i] = util.deepcopy(object)
		end
	end
	return result
end

-- Duplicates object for each vertex in nullModel's animation, leaving indicies specified in ignore empty
local function wrapLoopPath(nullModel, ignore, object)
	local result = {}
	local num_vertices = #nullModel.position_path
	local objects_list = newObjectList(num_vertices, ignore, object)
	for i = 1, num_vertices, 1 do
		if objects_list[i] then
			local thisObject = util.deepcopy(nullModel)
			thisObject.first_frame = i
			table.insert(thisObject.children, objects_list[i])
			table.insert(result, thisObject)
		end
	end
	return result
end

--============ BASIC OBJECTS: Returns stationary patterns of objects (Nestled in single stationary null) =======================================================================

-- On screen text
local function text(x, y, displayText, font, fontSize, color)
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
    return newCenteredNull({text})
end

 -- Basic "atomic" objects, including coin, spike, black_square, black_circle, all powerups, and others
function lb.basicObject(x, y, rot, object_type)
	local object = {}
	if object_type == "coin" then
		object.type = "coin"
		object.x = x
		object.y = y
		object.rotation = rot
	elseif object_type == "black_square" then
		object.type = "black_square"
		object.x = x
		object.y = y
		object.rotation = rot
	elseif object_type == "spike" then
		object.type = "spike"
		object.x = x
		object.y = y
		object.rotation = rot
	end
	return newCenteredNull({object})
end

function lb.doubleEdgeSpike(x, y, rot)
	local rot_rad = math.rad(rot)
	local newSpike = lb.basicObject(x, y, rot, "black_square")
	mergeObstacle(newSpike, lb.basicObject(x+math.sin(rot_rad), y-math.cos(rot_rad), rot, "spike"))
	mergeObstacle(newSpike, lb.basicObject(x-math.sin(rot_rad), y+math.cos(rot_rad), rot-180, "spike"))
	return newSpike
end

-- Circle pattern of objects
local function objectCircle(centerPoint, radius, deg_offset, num_objects, ignore, object)
	
end

-- Rigid line of objects, where startPoint is the center and space_width is the distance between the center of each object
-- local function fillLine(centerPoint, space_width, num_objects, ignore, object) -- Also don't know if I need this if I you can make a still line from simpleLine

--============ MODEL OBJECTS: Returns nulls with animated paths for use as models (single null object) =================================================================

-- Simple looping animated line (Objects jump from end back to beginning)
local function lineModel(startPoint, endPoint, num_objects, period, ease_pos, ease_rot) 
	if not ease_rot then ease_rot = easing.linear end
	if not ease_pos then ease_pos = easing.linear end

	local nullModel = {}
    nullModel.type = "null"
    nullModel.name = "LineModel"
    nullModel.position_interpolation = ease_pos
    nullModel.rotation_interpolation = ease_rot
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

-- Pingpong line (Objects reach end then play animation backwards to reach beginning)
local function pingpongLineModel(startPoint, endPoint, num_objects, period, ease_pos, ease_rot) end

-- 4 point square objects loop around
local function foursquareModel(centerPoint, edge_length, period, ease_pos, ease_rot) 
	if not ease_rot then ease_rot = easing.linear end
	if not ease_pos then ease_pos = easing.linear end

	local nullModel = {}
    nullModel.type = "null"
    nullModel.name = "4SquareModel"
    nullModel.position_interpolation = ease_pos
    nullModel.rotation_interpolation = ease_rot
    nullModel.on_complete = "loop"
    nullModel.children = {}

    -- Set position_path, rotation_path, transition_time
    local position_path = {}
    local rotation_path = {}
    local transition_time = {}
    local max = edge_length/2
    for i = 1, 4, 1 do
    	local xSign = 1
    	local ySign = 1
    	if (i == 1) or (i == 4) then
    		xSign = -1
    	end
    	if (i == 3) or (i == 4) then
    		ySign = -1
    	end

    	table.insert(position_path, util.newPoint(centerPoint.x + xSign*max, centerPoint.y + ySign*max))
    	table.insert(transition_time, period/4)
    	table.insert(rotation_path, 0)
    end
    nullModel.position_path = position_path
    nullModel.rotation_path = rotation_path
    nullModel.transition_time = transition_time

    return nullModel
end



-- local function rotatingCircleModel(centerPoint, radius, deg_offset, num_objects, period, ease) <-- You can probably make this

--============ ANIMATED OBJECTS: Returns animated patterns of objects (Nestled in single centered null) =========================================================================
local function simpleLine(startPoint, endPoint, num_objects, period, ignore, object, ease_pos, ease_rot) 
	if not ignore then ignore = {} end
	local lineModel = lineModel(startPoint, endPoint, num_objects, period, ease_pos, ease_rot)
	table.insert(ignore, num_objects+1) -- We don't want to double add the last object
	local result = wrapLoopPath(lineModel, ignore, object)
	return newCenteredNull(result)
end

local function pingpongLine(startPoint, endPoint, num_objects, period, ignore, object) end

local function foursquare(centerPoint, edge_length, period, ignore, object, ease_pos, ease_rot) 
	if not ignore then ignore = {} end
	local squareModel = foursquareModel(centerPoint, edge_length, period, ease_pos, ease_rot)
	local result = wrapLoopPath(squareModel, ignore, object)
	return newCenteredNull(result)
end

--============ FINISHED OBJECTS: Obstacles nestled within parent and ready for use in game (Nestled in parent null) ========================================================
function lb.newSimpleLine_(speed, startPoint, endPoint, num_objects, period, ignore, object, object_height)
	local obstacle = newParent(speed, "simpleLine_", -startPoint.y+(object_height/2), endPoint.y+(object_height/2))
	local line = simpleLine(startPoint, endPoint, num_objects, period, ignore, object)
	mergeObstacle(obstacle, line)
	return obstacle
end

function lb.newPingpongLine_(speed, startPoint, endPoint, num_objects, period, ignore, object) end

function lb.newSimpleFoursquare_(speed, centerPoint, edge_length, period, ignore, object, object_height) 
	local obstacle = newParent(speed, "simpleFoursqurae", -centerPoint.y+(edge_length/2)+(object_height/2), centerPoint.y+(edge_length/2)+(object_height/2))
	local line = foursquare(centerPoint, edge_length, period, ignore, object)
	mergeObstacle(obstacle, line)
	return obstacle
end

function lb.newCircle_(speed, centerPoint, radius, deg_offset, num_objects, ignore, object) end
function lb.newStillText_(speed, x, y, displayText, font, fontSize, color) end
function lb.fillAllColumns(speed, ignore_locations, object) end

function lb.literallyBlock(speed)
	local parent = newParent(speed, "literallyBlock", 1.5, 1.5)
	parent.children = {text(0, 0, "displayText", nil, 1, nil)}
	return parent
end

return lb