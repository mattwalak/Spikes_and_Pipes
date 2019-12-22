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
local _extraLeft = util.newPoint(-3*CN.COL_NUM/4, 0)
local _extraRight = util.newPoint(3*CN.COL_NUM/4, 0)

-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------


--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}

obstacles_list[1] = lb.newStillText_(speed, 0, 0, "Long tap for constant wind", 1, native.systemFont, {0,0,0})
obstacles_list[2] = lb.newFillAllColumns_(speed, 0, {1, 2, 3, 4}, lb.spike2Edge(0,0,0), 3, 1)
obstacles_list[6] = lb.newSimpleLine_(speed, _offLeft, _offRight, 2, -1, {1}, lb.basicObject(0,0,0,"coin"), .5)
obstacles_list[10] = lb.newFillAllColumns_(speed, 0, {14, 13, 12, 11}, lb.spike2Edge(0,0,0), 3, 1)
obstacles_list[14] = lb.newSimpleLine_(speed, _offLeft, _offRight, 2, -1, {1}, lb.basicObject(0,0,0,"coin"), .5)
obstacles_list[18] = lb.newFillAllColumns_(speed, 0, {1,2,3,4}, lb.spike2Edge(0,0,0), 3, 1)
obstacles_list[26] = lb.newStillText_(speed, 0, 0, "Tap far away for light wind", 1, native.systemFont, {0,0,0})
obstacles_list[27] = lb.newFillAllColumns_(speed, 0, {6, 7, 8, 9}, lb.spike2Edge(0,0,0), 3, 1)
obstacles_list[31] = lb.newFillAllColumns_(speed, 0, {4, 5, 6, 7}, lb.spike2Edge(0,0,0), 3, 1)
obstacles_list[35] = lb.newFillAllColumns_(speed, 0, {8, 9, 10, 11}, lb.spike2Edge(0,0,0), 3, 1)
obstacles_list[39] = lb.newPingpongFillColumns_(speed, -1, 1, 0, 2000, 2000, {6, 7, 8, 9}, lb.spike2Edge(0,0,0), 3, 1, easing.inOutSine, easing.inOutSine)


local level_2 =  {
    name = "Test level 2",
    victory = 60,
    obstacles = obstacles_list,
    startScore = 38
}

return level_2
