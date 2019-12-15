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

-- HELPER FUNCTIONS: Performs various operations to assist obstacle creation ==============================================================================

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
			table.insert(result, thisObject)
		end
	end
	return result
end

-- BASIC OBJECTS: Returns stationary patterns of objects (Nestled in single stationary null) =======================================================================

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
local function basicObject(x, y, rot, object_type)
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

local function doubleEdgeSpike(x, y, rot)
	local rot_rad = math.rad(rot)
	local newSpike = basicObject(x, y, rot, "black_square")
	mergeObstacle(newSpike, basicObject(x+math.sin(rot_rad), y-math.cos(rot_rad), rot, "spike"))
	mergeObstacle(newSpike, basicObject(x-math.sin(rot_rad), y+math.cos(rot_rad), rot-180, "spike"))
	return newSpike
end

-- Circle pattern of objects
-- local function objectCircle(centerPoint, radius, deg_offset, num_objects, ignore, object) -- Don't know if I need this if I make a circle animated thing

-- Rigid line of objects, where startPoint is the center and space_width is the distance between the center of each object
-- local function fillLine(centerPoint, space_width, num_objects, ignore, object) -- Also don't know if I need this if I you can make a still line from simpleLine

-- MODEL OBJECTS: Returns nulls with animated paths for use as models (single null object) =================================================================

-- Simple looping animated line (Objects jump from end back to beginning)
local function simpleLineModel(startPoint, endPoint, num_objects, period, ease) end

-- Pingpong line (Objects reach end then play animation backwards to reach beginning)
local function pingpongLineModel(startPoint, endPoint, num_objects, period, ease) end

-- 4 point square objects loop around
local function foursquareModel(centerPoint, edge_length, period, ease) end

-- local function rotatingCircleModel(centerPoint, radius, deg_offset, num_objects, period, ease) <-- You can probably make this

-- ANIMATED OBJECTS: Returns animated patterns of objects (Nestled in single centered null) =========================================================================
local function simpleLine(startPoint, endPoint, num_objects, period, ignore, object) end
local function pingpongLine(startPoint, endPoint, num_objects, period, ignore, object) end
local function foursquare(centerPoint, edge_length, period, ignore, object) end

-- FINISHED OBJECTS: Obstacles nestled within parent and ready for use in game (Nestled in parent null) ========================================================
function lb.newSimpleLine_(speed, startPoint, endPoint, num_objects, period, ignore, object) end
function lb.newPingpongLine_(speed, startPoint, endPoint, num_objects, period, ignore, object) end
function lb.newFoursquare_(speed, centerPoint, edge_length, period, ignore, object) end
function lb.newCircle_(speed, centerPoint, radius, deg_offset, num_objects, ignore, object) end
function lb.newStillText_(speed, x, y, displayText, font, fontSize, color) end
function lb.fillAllColumns(speed, ignore_locations, object) end

function lb.literallyBlock(speed)
	local parent = newParent(speed, "literallyBlock", 1.5, 1.5)
	parent.children = {text(0, 0, "displayText", nil, 1, nil)}
	return parent
end

return lb