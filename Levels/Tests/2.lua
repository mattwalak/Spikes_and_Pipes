local CN = require("crazy_numbers")
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
local s1 = util.newPoint(_left-_halfSpikeWidth, 0)
local e1 = util.newPoint(_right+_halfSpikeWidth, 0)

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[1] = util.coinCircle_(speed, 2, 8)
obstacles_list[2] = util.spikeLine_(speed, s1, e1, 1, 4000)
obstacles_list[8] = util.spikeLine_(speed, e1, s1, 1, 4000)
obstacles_list[15] = util.spikeLine_(speed, s1, e1, 2, 4000)
obstacles_list[18] = util.spikeLine_(speed, e1, s1, 2, 4000)
obstacles_list[21] = util.spikeLine_(speed, s1, e1, 2, 4000)


local level_2 =  {
    name = "Test level 2",
    speed = 10,
    victory = 30,
    obstacles = obstacles_list,
}

return level_2
