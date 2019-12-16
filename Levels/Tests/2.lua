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

-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000

-- Define obstacles ------------------------------------------------------------
local s1 = util.newPoint(-7, 1)
local e1 = util.newPoint(7, -1)

local s2 = util.newPoint(-7-2-.5-3, 0)
local e2 = util.newPoint(7+2+.5+3, 0)

local c1 = util.newPoint(0,0)

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}

obstacles_list[1] = lb.newPingpongLine_(speed, s1, e1, 0, 360, 1000, 1000, lb.spike2Edge(0,0,0), 1.5, easing.inOutSine)
-- obstacles_list[1] = lb.newSimpleLine_(speed, s1, e1, 3, 4000, nil, lb.spike2Edge(0,0,0), 1.5)
-- obstacles_list[1] = lb.newFillAllColumns_(speed, 1, {1, 14}, lb.spike2Edge(0,0,0), 3, 1)
-- obstacles_list[1] = lb.newSquareLine_(speed, s2, e2, 2, 8000, nil, c1, 4, 4000, nil, lb.spike2Edge(0,0,0), 1.5)
--obstacles_list[1] = util.fillHorizontalLine_(speed, nil, "coin")
--obstacles_list[5] = util.fillHorizontalLine_(speed, nil, "spike")

--[[
obstacles_list[1] = util.coinCircle_(speed, 2, 8)
obstacles_list[8] = util.spikeLine_(speed, s1, e1, 3, 8000)
obstacles_list[14] = util.spikeLine_(speed, e1, s1, 3, 8000)
obstacles_list[20] = util.spikeLine_(speed, s1, e1, 4, 8000)
obstacles_list[25] = util.spikeLine_(speed, e1, s1, 4, 8000)
obstacles_list[30] = util.spikeLine_(speed, s1, e1, 4, 8000)
obstacles_list[36] = spikeSquare]]--

local level_2 =  {
    name = "Test level 2",
    speed = 50,
    victory = 60,
    obstacles = obstacles_list,
}

return level_2
