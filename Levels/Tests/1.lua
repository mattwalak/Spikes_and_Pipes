local CN = require("crazy_numbers")
local lb = require("level_builder")
local util = require("util")

-- Helpful numbers
local _left = -CN.COL_NUM/2
local _right = CN.COL_NUM/2
local _top = (display.contentHeight/CN.COL_WIDTH)/2
local _bottom = -(display.contentHeight/CN.COL_WIDTH)/2
local _halfSpikeWidth = CN.SPIKE_WIDTH/2
local _halfSpikeHeight = CN.SPIKE_HEIGHT/2
local _offLeft = util.newPoint(_left - _halfSpikeWidth, 0)
local _offRight = util.newPoint(_right + _halfSpikeWidth, 0)
local _center = util.newPoint(0,0)

-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------


--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}

local extraLeft = util.newPoint(-3*CN.COL_NUM/4, 0)
local extraRight = util.newPoint(3*CN.COL_NUM/4, 0)

obstacles_list[1] = lb.newStillText_(speed, 0, 0, "Tap to blow wind", 1, native.systemFont, {0,0,0})
obstacles_list[12] = lb.newStillText_(speed, 0, 0, "Collect the coins", 1, native.systemFont, {0,0,0})
obstacles_list[13] = lb.newSimpleLine_(speed, _offLeft, _offRight, 2, -1, {1}, lb.basicObject(0,0,0,"coin"), .5)
obstacles_list[17] = lb.newSimpleLine_(speed, _offLeft, _offRight, 4, -1, {1,3}, lb.basicObject(0,0,0,"coin"), .5)
obstacles_list[21] = lb.newSimpleLine_(speed, _offLeft, _offRight, 2, -1, {1}, lb.basicObject(0,0,0,"coin"), .5)
obstacles_list[25] = lb.newCircle_(speed, _center, 4, 0, 8, nil, lb.basicObject(0,0,0,"coin"), .5)
obstacles_list[32] = lb.newStillText_(speed, 0, 0, "Avoid the spikes!", 1, native.systemFont, {0,0,0})
obstacles_list[33] = lb.newSimpleLine_(speed, _offLeft, _offRight, 2, -1, {1}, lb.spike2Edge(0,0,0), 3)
obstacles_list[37] = lb.newSimpleLine_(speed, _offLeft, _offRight, 4, -1, {1,3}, lb.spike2Edge(0,0,0), 3)
obstacles_list[41] = lb.newSimpleLine_(speed, _offLeft, _offRight, 2, -1, {1}, lb.spike2Edge(0,0,0), 3)

local level_1 =  {
    name = "Test level 1",
    victory = 60,
    obstacles = obstacles_list,
}

return level_1
