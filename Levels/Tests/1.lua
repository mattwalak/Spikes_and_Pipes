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


--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[1] = util.stillText_(speed, 0, 0, "Hello!", native.systemFont, 1, {0,0,0})
obstacles_list[2] = util.stillSpikeLine_(speed, 3, {2})
obstacles_list[17] = util.stillSpikeLine_(speed, 3, {2})
obstacles_list[20] = util.stillSpikeLine_(speed, 3, {2})
obstacles_list[23] = util.stillSpikeLine_(speed, 3, {2})
obstacles_list[26] = util.stillSpikeLine_(speed, 1)
obstacles_list[29] = util.stillSpikeLine_(speed, 3, {2})
obstacles_list[32] = util.stillSpikeLine_(speed, 1)

local level_1 =  {
    name = "Test level 1",
    victory = 43,
    obstacles = obstacles_list,
}

return level_1
