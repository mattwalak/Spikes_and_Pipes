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
local _offLeft = util.newPoint(_left - _halfSpikeWidth, 0)
local _offRight = util.newPoint(_right + _halfSpikeWidth, 0)
local _inLeft = util.newPoint(_left + _halfSpikeWidth, 0)
local _inRight = util.newPoint(_right - _halfSpikeWidth, 0)
local _center = util.newPoint(0,0)

--============ HELPER FUNCTIONS: Performs various operations to assist obstacle creation ==============================================================================

-- Takes all children from obstacle2 and adds them to obstacle1
function mergeObstacle(ob1, ob2)
    util.tableExtend(ob1.children, ob2.children)
end

-- Wraps list of objects into a single stationary null centered at (x,y)
local function wrapNull(x, y, object_list)
	local centeredNull = {
		type = "null",
		name = "centered_null",
        position_path = {util.newPoint(x, y), util.newPoint(x, y)},
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
local function text(x, y, displayText, fontSize, font, color)
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

function lb.spike2Edge(x, y, rot)
	local rot_rad = math.rad(rot)
	local newSpike = lb.basicObject(x, y, rot, "black_square")
	mergeObstacle(newSpike, lb.basicObject(x+math.sin(rot_rad), y-math.cos(rot_rad), rot, "spike"))
	mergeObstacle(newSpike, lb.basicObject(x-math.sin(rot_rad), y+math.cos(rot_rad), rot-180, "spike"))
	return newSpike
end

-- Circle pattern of objects
local function objectCircle(centerPoint, radius, deg_offset, num_objects, ignore, object)
	local rad_offset = math.rad(deg_offset)
	local objects = newObjectList(num_objects, ignore, object)
	local positioned_objects = {}
	local angle = 2*math.pi/num_objects
	for i = 1, num_objects, 1 do
		if objects[i] then
			local newNull = wrapNull(radius*math.cos(deg_offset+i*angle),radius*math.sin(deg_offset+i*angle), {objects[i]})
			table.insert(positioned_objects, newNull)
		end
	end
	return wrapNull(0,0,positioned_objects)
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

-- Creates a pingpong line with a single object completing a single revolution in 'period_1 + period_2' time
local function pingpongLine(startPoint, endPoint, start_rot, end_rot, period_1, period_2, object, ease_pos, ease_rot)
	if not ease_pos then ease_pos = easing.linear end
	if not ease_rot then ease_rot = ease_pos end

	local line = {
		type = "null",
		name = "pingpongLine",
        position_path = {startPoint, endPoint},
        rotation_path = {start_rot,end_rot},
        transition_time = {period_1, period_2},
        position_interpolation = ease_pos,
        rotation_interpolation = ease_rot,
        on_complete = "loop",
        first_frame = 1,
        children = {util.deepcopy(object)}
	}

	return wrapNull(0,0,{line})
end

local function foursquare(centerPoint, edge_length, period, ignore, object, ease_pos, ease_rot) 
	if not ignore then ignore = {} end
	local squareModel = foursquareModel(centerPoint, edge_length, period, ease_pos, ease_rot)
	local result = wrapLoopPath(squareModel, ignore, object)
	return newCenteredNull(result)
end

local function pingpongFillColumns(start_x_offset, end_x_offset, y, period_1, period_2, ignore, object, object_height, object_width, ease_pos, ease_rot)
	if not ignore then ignore = {} end
	
	-- Find most positive and most negative x (For extra filling of obstacles)
	local mostNegative_x = 0
	local mostPositive_x = 0
	if start_x_offset < 0 then
		if end_x_offset < start_x_offset then
			mostNegative_x = end_x_offset
		else
			mostNegative_x = start_x_offset
		end
	elseif end_x_offset < 0 then
		mostNegative_x = end_x_offset
	end

	if start_x_offset > 0 then
		if end_x_offset > start_x_offset then
			mostPositive_x = end_x_offset
		else
			mostPositive_x = start_x_offset
		end
	elseif end_x_offset > 0 then
		mostPositive_x = end_x_offset
	end

	local startPoint = util.newPoint(_left-mostPositive_x+(object_width/2), y)
	local endPoint = util.newPoint(_right-mostNegative_x+(object_width/2), y)
	local r_start = util.newPoint(start_x_offset, 0)
	local r_end = util.newPoint(end_x_offset, 0)

	for i = 1, #ignore, 1 do
		-- Our ignore values are now off because of the padding we added
		ignore[i] = ignore[i] + mostPositive_x
	end

	local line = simpleLine(startPoint, endPoint, CN.COL_NUM+mostPositive_x-mostNegative_x, -1, ignore, object)
	local animatedLine = pingpongLine(r_start, r_end, 0, 0, period_1, period_2, line, ease_pos, ease_rot)
	return animatedLine
end

local function spinObject(anchorPoint, clockwise, deg_offset, period, object)
	local objects = wrapNull(-anchorPoint.x, -anchorPoint.y, {object})

	local off1 = 360
	local off2 = 0
	if clockwise then
		off1 = 0
		off2 = 360
	end
	local spin = {
		type = "null",
		name = "spinObject",
        position_path = {anchorPoint, anchorPoint},
        rotation_path = {deg_offset+off1, deg_offset+off2},
        transition_time = {0, period},
        position_interpolation = ease_pos,
        rotation_interpolation = ease_rot,
        on_complete = "loop",
        first_frame = 1,
        children = {objects}
	}

	return wrapNull(0,0,{spin})
end

local function fan(centerPoint, clockwise, radius, deg_offset, period, num_objects, ignore, object, object_height)
	local line = simpleLine(util.newPoint(-radius+.5, 0), util.newPoint(radius+.5, 0), num_objects, -1, ignore, object)
	local zero = util.newPoint(0,0)
	local off1 = 360
	local off2 = 0
	if clockwise then
		off1 = 0
		off2 = 360
	end


	local fan = {
		type = "null",
		name = "fan",
        position_path = {zero, zero},
        rotation_path = {deg_offset+off1, deg_offset+off2},
        transition_time = {0, period},
        position_interpolation = ease_pos,
        rotation_interpolation = ease_rot,
        on_complete = "loop",
        first_frame = 1,
        children = {line}
	}

	return wrapNull(centerPoint.x,centerPoint.y,{fan})
end

local function doubleThwomp(height)
	local left = simpleLine(util.newPoint(_left, .5), util.newPoint(), num_objects, period, ignore, object, ease_pos, ease_rot) 
end


--============ FINISHED OBJECTS: Obstacles nestled within parent and ready for use in game (Nestled in parent null) ========================================================
function lb.newSimpleLine_(speed, startPoint, endPoint, num_objects, period, ignore, object, object_height)
	local obstacle = newParent(speed, "newSimpleLine_", startPoint.y+(object_height/2), -endPoint.y+(object_height/2))
	local line = simpleLine(startPoint, endPoint, num_objects, period, ignore, object)
	mergeObstacle(obstacle, line)
	return obstacle
end

function lb.newPingpongLine_(speed, startPoint, endPoint, start_rot, end_rot, period_1, period_2, object, object_height, ease_pos, ease_rot) 
	local obstacle = newParent(speed, "newPingpongLine_", startPoint.y+(object_height/2), -endPoint.y+(object_height/2))
	local line = pingpongLine(startPoint, endPoint, start_rot, end_rot, period_1, period_2, object, ease_pos, ease_rot)
	mergeObstacle(obstacle, line)
	return obstacle
end

function lb.newSimpleFoursquare_(speed, centerPoint, edge_length, period, ignore, object, object_height) 
	local obstacle = newParent(speed, "newSimpleFoursquare_", centerPoint.y+(edge_length/2)+(object_height/2), -centerPoint.y+(edge_length/2)+(object_height/2))
	local line = foursquare(centerPoint, edge_length, period, ignore, object)
	mergeObstacle(obstacle, line)
	return obstacle
end

function lb.newCircle_(speed, centerPoint, radius, deg_offset, num_objects, ignore, object, object_height) 
	local obstacle = newParent(speed, "newCircle_", centerPoint.y+radius+(object_height/2), -centerPoint.y+radius+(object_height/2))
	local circle = objectCircle(centerPoint, radius, deg_offset, num_objects, ignore, object)
	mergeObstacle(obstacle, circle)
	return obstacle
end

function lb.newStillText_(speed, x, y, displayText, fontSize, font, color) 
	local parent = newParent(speed, "newStillText_", fontSize/2, fontSize/2)
	parent.children = {text(x, y, displayText, fontSize, font, color)}
	return parent
end

function lb.newFillAllColumns_(speed, y, ignore, object, object_height, object_width) 
	local obstacle = newParent(speed, "newFillAllColumns_", y+(object_height/2), -y+(object_height/2))
	local startPoint = util.newPoint(_left+(object_width/2), y)
	local endPoint = util.newPoint(_right+(object_width/2), y)
	local line = simpleLine(startPoint, endPoint, CN.COL_NUM, -1, ignore, object)
	mergeObstacle(obstacle, line)
	return obstacle
end

function lb.newSquareLine_(speed, line_start, line_end, line_numSquares, line_period, line_ignore, square_center, square_edgeLength, square_period, square_ignore, square_object, square_objectHeight)
	local obstacle = newParent(speed, "newSquareLine_", line_start.y+(square_edgeLength/2)+(square_objectHeight/2), -line_start.y+(square_edgeLength/2)+(square_objectHeight/2))
	local square = foursquare(square_center, square_edgeLength, square_period, square_ignore, square_object) 	
	local line = simpleLine(line_start, line_end, line_numSquares, line_period, line_ignore, square)
	mergeObstacle(obstacle, line)
	return obstacle
end

function lb.newPingpongFillColumns_(speed, start_x_offset, end_x_offset, y, period_1, period_2, ignore, object, object_height, object_width, ease_pos, ease_rot)
	if not ignore then ignore = {} end
	local obstacle = newParent(speed, "newPingpongFillColumns_", y+(object_height/2), -y+(object_height/2))
	local line = pingpongFillColumns(start_x_offset, end_x_offset, y, period_1, period_2, ignore, object, object_height, object_width, ease_pos, ease_rot)
	mergeObstacle(obstacle, line)
	return obstacle
end

-- NOTE: object_height/2 method only works if deg_offset = 0
function lb.newFan_(speed, clockwise, centerPoint, radius, deg_offset, period, num_objects, ignore, object, object_height)
	local obstacle = newParent(speed, "newFan_", centerPoint.y+radius+.5, -centerPoint.y+radius+.5)
	local fan = fan(centerPoint, clockwise, radius, deg_offset, period, num_objects, ignore, object, object_height)
	mergeObstacle(obstacle, fan)
	return obstacle
end

function lb.newDoubleThwomp_(speed, height)
	local obstacle = newParent(speed, "newDoubleThwomp_", height-.5, .5)
	local thwomp = doubleThwomp(height)
	mergeObstacle(obstacle, thwomp)
	return obstacle
end

--============ FINISHED GROUPED OBSTACLES: Game ready collections of finished obstacles ========================================================
-- Minimal parameters required


function lb.threeLineSpike_(speed)
	local obstacle = newParent(speed, "threeLineEasy_", 1.5, 16+1.5)
	local left = -(3/4)*CN.COL_NUM
	local right = (3/4)*CN.COL_NUM
	local line1 = simpleLine(util.newPoint(left, 0), util.newPoint(right, 0), 2, 8000, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local line2 = simpleLine(util.newPoint(right, -8), util.newPoint(left, -8), 2, 8000, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local line2_coin = simpleLine(util.newPoint(right, -7), util.newPoint(left, -7), 4, 8000, {1,3}, lb.basicObject(0,0,0,"coin"), easing.linear, easing.linear) 
	local line3 = simpleLine(util.newPoint(left, -16), util.newPoint(right, -16), 2, 8000, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 

	mergeObstacle(obstacle, line1)
	mergeObstacle(obstacle, line2)
	mergeObstacle(obstacle, line2_coin)
	mergeObstacle(obstacle, line3)

	return obstacle
end

function lb.threeLineSquare_(speed)
	local smallSquareSize = 6
	local largeSquareSize = 10
	local obstacle_width = 1
	local obstacle_height = 3
	local extra_width = 4
	local line_dist = 18

	local obstacle = newParent(speed, "threeLineSquare_", (obstacle_height/2)+(smallSquareSize/2), (2*line_dist)+(obstacle_height/2)+(smallSquareSize/2))
	local left = -(1/2)*CN.COL_NUM-(largeSquareSize/2)-(obstacle_width/2)-extra_width
	local right = (1/2)*CN.COL_NUM+(largeSquareSize/2)+(obstacle_width/2)+extra_width
	
	local square_period = 8000

	local smallSquare = foursquare(util.newPoint(0,0), smallSquareSize, square_period, nil, lb.spike2Edge(0,0,0)) 	
	local largeSquare = foursquare(util.newPoint(0,0), largeSquareSize, square_period, nil, lb.spike2Edge(0,0,0)) 

	local line1 = simpleLine(util.newPoint(left, 0), util.newPoint(right, 0), 2, 8000, nil, smallSquare, easing.linear, easing.linear) 
	local line2 = simpleLine(util.newPoint(right, -line_dist), util.newPoint(left, -line_dist), 2, 8000, nil, largeSquare, easing.linear, easing.linear) 
	local line2_coin = simpleLine(util.newPoint(right, -line_dist), util.newPoint(left, -line_dist), 2, 8000, nil, lb.basicObject(0,0,0,"coin"), easing.linear, easing.linear) 
	local line3 = simpleLine(util.newPoint(left, -2*line_dist), util.newPoint(right, -2*line_dist), 2, 8000, nil, smallSquare, easing.linear, easing.linear) 

	mergeObstacle(obstacle, line1)
	mergeObstacle(obstacle, line2)
	mergeObstacle(obstacle, line2_coin)
	mergeObstacle(obstacle, line3)

	return obstacle
end

function lb.zigzag_(speed)
	local period = 5000
	local obstacle_width = 1
	local obstacle_height = 3
	local extra_width = 2
	local slope_height = 5
	local line_dist = 10
	local left = -(CN.COL_NUM/2)-(obstacle_width/2)-extra_width
	local right = (CN.COL_NUM/2)+(obstacle_width/2)+extra_width

	local obstacle = newParent(speed, "diagonalLatice1_", obstacle_height/2, 2*line_dist+(obstacle_height/2))

	-- simpleLine(startPoint, endPoint, num_objects, period, ignore, object, ease_pos, ease_rot) 
	local left_line_1 = simpleLine(util.newPoint(left, -slope_height), util.newPoint(right, 0), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local left_line_2 = simpleLine(util.newPoint(left, -slope_height-line_dist), util.newPoint(right, -line_dist), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local right_line_1 = simpleLine(util.newPoint(right, -slope_height-(line_dist/2)), util.newPoint(left, -(line_dist/2)), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local right_line_2 = simpleLine(util.newPoint(right, -line_dist-slope_height-(line_dist/2)), util.newPoint(left, -line_dist-(line_dist/2)), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 


	mergeObstacle(obstacle, left_line_1)
	mergeObstacle(obstacle, left_line_2)
	mergeObstacle(obstacle, right_line_1)
	mergeObstacle(obstacle, right_line_2)

	return obstacle
end

function lb.diagonalLatice1_(speed)
	local period = 6000
	local obstacle_width = 1
	local obstacle_height = 3
	local extra_width = 4
	local slope_height = 12
	local line_dist = 8
	local start_offset = line_dist/2
	local left = -(CN.COL_NUM/2)-(obstacle_width/2)-extra_width
	local right = (CN.COL_NUM/2)+(obstacle_width/2)+extra_width

	local obstacle = newParent(speed, "diagonalLatice1_", obstacle_height/2, start_offset+line_dist+slope_height+(obstacle_height/2))

	-- simpleLine(startPoint, endPoint, num_objects, period, ignore, object, ease_pos, ease_rot) 
	local left_line_1 = simpleLine(util.newPoint(left, -slope_height), util.newPoint(right, 0), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local left_line_2 = simpleLine(util.newPoint(left, -slope_height-line_dist), util.newPoint(right, -line_dist), 4, period, {1,3}, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local right_line_1 = simpleLine(util.newPoint(right, -slope_height-start_offset), util.newPoint(left, -start_offset), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local right_line_2 = simpleLine(util.newPoint(right, -line_dist-slope_height-start_offset), util.newPoint(left, -line_dist-start_offset), 4, period, {1,3}, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 

	mergeObstacle(obstacle, left_line_1)
	mergeObstacle(obstacle, left_line_2)
	mergeObstacle(obstacle, right_line_1)
	mergeObstacle(obstacle, right_line_2)

	return obstacle
end

function lb.diagonalLatice2_(speed)
	local period = 6000
	local obstacle_width = 1
	local obstacle_height = 3
	local extra_width = 4
	local slope_height = 8
	local line_dist = 8
	local start_offset = 0
	local left = -(CN.COL_NUM/2)-(obstacle_width/2)-extra_width
	local right = (CN.COL_NUM/2)+(obstacle_width/2)+extra_width

	local obstacle = newParent(speed, "diagonalLatice1_", obstacle_height/2, start_offset+line_dist+slope_height+(obstacle_height/2))

	-- simpleLine(startPoint, endPoint, num_objects, period, ignore, object, ease_pos, ease_rot) 
	local left_line_1 = simpleLine(util.newPoint(left, -slope_height), util.newPoint(right, 0), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local left_line_2 = simpleLine(util.newPoint(left, -slope_height-line_dist), util.newPoint(right, -line_dist), 4, period, {1,3}, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local right_line_1 = simpleLine(util.newPoint(right, -slope_height-start_offset), util.newPoint(left, -start_offset), 2, period, nil, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 
	local right_line_2 = simpleLine(util.newPoint(right, -line_dist-slope_height-start_offset), util.newPoint(left, -line_dist-start_offset), 4, period, {1,3}, lb.spike2Edge(0,0,0), easing.linear, easing.linear) 

	mergeObstacle(obstacle, left_line_1)
	mergeObstacle(obstacle, left_line_2)
	mergeObstacle(obstacle, right_line_1)
	mergeObstacle(obstacle, right_line_2)

	return obstacle
end

function lb.singleSquare_(speed)
	-- lb.newSimpleFoursquare_(speed, centerPoint, edge_length, period, ignore, object, object_height)
	return lb.newSimpleFoursquare_(speed, util.newPoint(0,0), 10, 8000, nil, lb.spike2Edge(0,0,0), 3) 
end

function lb.multiple1Square_(speed)
	local period = 8000
	local squareSize = 12
	local square_dist = 6
	local object_width = 1
	local object_height = 3

	-- lb.newSimpleFoursquare_(speed, centerPoint, edge_length, period, ignore, object, object_height)
	local obstacle = newParent(speed, "multiple2Square_",(squareSize/2)+(object_height/2),3*square_dist+(squareSize/2)+(object_height/2))
	local square1 = lb.newSimpleFoursquare_(speed, util.newPoint(0,0), squareSize, period, {1, 2, 3}, lb.spike2Edge(0,0,0), 3)
	local square2 = lb.newSimpleFoursquare_(speed, util.newPoint(0,-square_dist), squareSize, period, {2, 3, 4}, lb.spike2Edge(0,0,0), 3)
	local square3 = lb.newSimpleFoursquare_(speed, util.newPoint(0,-2*square_dist), squareSize, period, {3, 4, 1}, lb.spike2Edge(0,0,0), 3)
	local square4 = lb.newSimpleFoursquare_(speed, util.newPoint(0,-3*square_dist), squareSize, period, {4, 1, 2}, lb.spike2Edge(0,0,0), 3)

	local coin1 = lb.newSimpleFoursquare_(speed, util.newPoint(0,0), squareSize, period, {1, 3, 4}, lb.basicObject(0,0,0, "coin"), 1)
	local coin2 = lb.newSimpleFoursquare_(speed, util.newPoint(0,-square_dist), squareSize, period, {1, 2, 4}, lb.basicObject(0,0,0, "coin"), 1)
	local coin3 = lb.newSimpleFoursquare_(speed, util.newPoint(0,-2*square_dist), squareSize, period, {1, 2, 3}, lb.basicObject(0,0,0, "coin"), 1)
	local coin4 = lb.newSimpleFoursquare_(speed, util.newPoint(0,-3*square_dist), squareSize, period, {2, 3, 4}, lb.basicObject(0,0,0, "coin"), 1)

	mergeObstacle(obstacle, square1)
	mergeObstacle(obstacle, square2)
	mergeObstacle(obstacle, square3)
	mergeObstacle(obstacle, square4)
	mergeObstacle(obstacle, coin1)
	mergeObstacle(obstacle, coin2)
	mergeObstacle(obstacle, coin3)
	mergeObstacle(obstacle, coin4)

	return obstacle
end

function lb.fourSmall2Squares_(speed)
	local smallSquareSize = 3
	local smallSquarePeriod = 4000
	local largeSquareSize = 12
	local largeSquarePeriod = 10000
	local object_height = 3

	local obstacle = newParent(speed, "fourSmall2Squares_", (largeSquareSize/2)+(smallSquareSize/2)+(object_height/2), (largeSquareSize/2)+(smallSquareSize/2)+(object_height/2))

	local smallSquare_1 = foursquare(util.newPoint(0,0), smallSquareSize, smallSquarePeriod, {1, 3}, lb.spike2Edge(0,0,0)) 	
	local smallSquare_2 = foursquare(util.newPoint(0,0), smallSquareSize, smallSquarePeriod, {2, 4}, lb.spike2Edge(0,0,0)) 	
	local largeSquare_1 = foursquare(util.newPoint(0,0), largeSquareSize, largeSquarePeriod, {2, 4}, smallSquare_1) 	
	local largeSquare_2 = foursquare(util.newPoint(0,0), largeSquareSize, largeSquarePeriod, {1, 3}, smallSquare_2) 
	local centerCoin = {lb.basicObject(0,0,0,"coin")}
	mergeObstacle(obstacle, largeSquare_1)
	mergeObstacle(obstacle, largeSquare_2)
	util.tableExtend(obstacle.children, centerCoin)
	return obstacle
end

function lb.threeFans_(speed)
	local period = 8000
	local fan_length = CN.COL_NUM/2
	local fan_space = CN.COL_NUM

	local obstacle = newParent(speed, "threeFans_", fan_length/2, 2*fan_space+fan_length/2)
	local object_width = 1

	local startPoint = util.newPoint(_left+(object_width/2), 0)
	local endPoint = util.newPoint(_right+(object_width/2), 0)
	local fan_line = simpleLine(startPoint, endPoint, CN.COL_NUM, -1, nil, lb.spike2Edge(0,0,0))
	local spinThings_1 = spinObject(util.newPoint(0,0), true, 0, period, fan_line)
	local spinThings_2 = spinObject(util.newPoint(0,-fan_space), false, 0, period, wrapNull(0, -fan_space, {fan_line}))
	local spinThings_3 = spinObject(util.newPoint(0,-2*fan_space), true, 0, period, wrapNull(0, -2*fan_space, {fan_line}))

	mergeObstacle(obstacle, spinThings_1)
	mergeObstacle(obstacle, spinThings_2)
	mergeObstacle(obstacle, spinThings_3)
	return obstacle
end

function lb.threePingpongLines_(speed)
	local period_1 = 1500
	local period_2 = 1500
	local line_dist = 9
	local object_height = 3

	local left = _offLeft.x
	local right = _offRight.x
	local obstacle = newParent(speed, "threePingpongLines_", object_height/2, 2*line_dist+(object_height/2)) 

	-- pingpongLine(startPoint, endPoint, start_rot, end_rot, period_1, period_2, object, ease_pos, ease_rot)
	local line_1 = pingpongLine(util.newPoint(left, 0), util.newPoint(right, 0), 0, 0, period_1, period_2, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_2 = pingpongLine(util.newPoint(right, -line_dist), util.newPoint(left, -line_dist), 0, 0, period_1, period_2, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_3 = pingpongLine(util.newPoint(left, -2*line_dist), util.newPoint(right, -2*line_dist), 0, 0, period_1, period_2, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	
	mergeObstacle(obstacle, line_1)
	mergeObstacle(obstacle, line_2)
	mergeObstacle(obstacle, line_3)

	return obstacle
end

function lb.fourOffsyncPingpongLines_(speed)
	local period_A1 = 1500
	local period_A2 = 1500
	local period_B1 = 3000
	local period_B2 = 3000
	local period_C1 = 4500
	local period_C2 = 4500
	local period_D1 = 6000
	local period_D2 = 6000
	local line_dist = 3
	local object_height = 3

	local left = _inLeft.x
	local right = _inRight.x
	local obstacle = newParent(speed, "threePingpongLines_", object_height/2, 3*line_dist+(object_height/2)) 

	-- pingpongLine(startPoint, endPoint, start_rot, end_rot, period_1, period_2, object, ease_pos, ease_rot)
	local line_1 = pingpongLine(util.newPoint(left, 0), util.newPoint(right, 0), 0, 0, period_A1, period_A2, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_2 = pingpongLine(util.newPoint(left, -line_dist), util.newPoint(right, -line_dist), 0, 0, period_B1, period_B2, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_3 = pingpongLine(util.newPoint(left, -2*line_dist), util.newPoint(right, -2*line_dist), 0, 0, period_C1, period_C2, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_4 = pingpongLine(util.newPoint(left, -3*line_dist), util.newPoint(right, -3*line_dist), 0, 0, period_D1, period_D2, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	
	mergeObstacle(obstacle, line_1)
	mergeObstacle(obstacle, line_2)
	mergeObstacle(obstacle, line_3)
	mergeObstacle(obstacle, line_4)

	return obstacle
end

function lb.pingpongThreeGrid_(speed)
	local left = _inLeft.x
	local right = _inRight.x
	local height = 14
	local object_height = 3
	local period = 3000

	local obstacle = newParent(speed, "pingpongThreeGrid_", object_height/2, height+(object_height/2))

	local line_1 = pingpongLine(util.newPoint(left, -height), util.newPoint(left, 0), 0, 0, period, period, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_2 = pingpongLine(util.newPoint(0, 0), util.newPoint(0, -height), 0, 0, period, period, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_3 = pingpongLine(util.newPoint(right, -height), util.newPoint(right, 0), 0, 0, period, period, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	
	local line_4 = pingpongLine(util.newPoint(left, 0), util.newPoint(right, 0), 0, 0, period, period, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_5 = pingpongLine(util.newPoint(right, -height/2), util.newPoint(left, -height/2), 0, 0, period, period, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)
	local line_6 = pingpongLine(util.newPoint(left, -height), util.newPoint(right, -height), 0, 0, period, period, lb.spike2Edge(0,0,0), easing.inOutSine, easing.inOutSine)


	mergeObstacle(obstacle, line_1)
	mergeObstacle(obstacle, line_2)
	mergeObstacle(obstacle, line_3)
	mergeObstacle(obstacle, line_4)
	mergeObstacle(obstacle, line_5)
	mergeObstacle(obstacle, line_6)

	return obstacle
end

function lb.pingpongPath_(speed)
	local height = 30
	local width = 8
	local object_width = 1
	local object_height = 3
	local move_dist = 3
	local period_1 = 2000
	local period_2 = 2000
	local left = _left+(object_width/2)
	local right = _right+(object_width/2)

	-- pingpongLine(startPoint, endPoint, start_rot, end_rot, period_1, period_2, object, ease_pos, ease_rot)
	local obstacle = newParent(speed, "pingpongPath_", object_height/2, height+(object_height/2))

	local start_line = simpleLine(util.newPoint(left, 0), util.newPoint(right, 0), CN.COL_NUM, -1, {5, 6, 7, 8, 9, 10}, lb.spike2Edge(0,0,0))

	local left_side_bar = simpleLine(util.newPoint(-width/2, -2), util.newPoint(-width/2, -height+1), height-3, -1, nil, lb.spike2Edge(0,0,90))
	local left_side = pingpongLine(util.newPoint(-move_dist/2, 0), util.newPoint(move_dist/2, 0), 0, 0, period_1, period_2, left_side_bar, easing.inOutSine, easing.inOutSine)
	local right_side_bar = simpleLine(util.newPoint(width/2, -2), util.newPoint(width/2, -height+1), height-3, -1, nil, lb.spike2Edge(0,0,90))
	local right_side = pingpongLine(util.newPoint(-move_dist/2, 0), util.newPoint(move_dist/2, 0), 0, 0, period_1, period_2, right_side_bar, easing.inOutSine, easing.inOutSine)

	local end_line = simpleLine(util.newPoint(left, -height), util.newPoint(right, -height), CN.COL_NUM, -1, {5, 6, 7, 8, 9, 10}, lb.spike2Edge(0,0,0))

	mergeObstacle(obstacle, start_line)
	mergeObstacle(obstacle, end_line)
	mergeObstacle(obstacle, left_side)
	mergeObstacle(obstacle, right_side)

	return obstacle
end

function lb.sinePath_(speed)
	
end

return lb