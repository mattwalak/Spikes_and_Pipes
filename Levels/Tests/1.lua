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

--[[
obstacles_list[1] = util.fillHorizontalLine_(speed, {10, 11, 12, 13, 14}, "spike")
obstacles_list[4] = util.stillLine_(speed, 1, nil, "coin")
obstacles_list[7] = util.fillHorizontalLine_(speed, {1, 2, 3, 4, 5}, "spike")
obstacles_list[10] = util.stillLine_(speed, 1, nil, "coin")
obstacles_list[13] = util.fillHorizontalLine_(speed, {10, 11, 12, 13, 14}, "spike")
obstacles_list[16] = util.stillLine_(speed, 1, nil, "coin")
obstacles_list[19] = util.fillHorizontalLine_(speed, {1, 2, 3, 4, 5}, "spike")
]]--



obstacles_list[1] = util.stillText_(speed, 0, 0, "Tap to blow wind", native.systemFont, 1, {0,0,0})
obstacles_list[12] = util.stillText_(speed, 0, 0, "Collect the coins", native.systemFont, 1, {0,0,0})
obstacles_list[13] = util.stillLine_(speed, 1, nil, "coin")
obstacles_list[17] = util.stillLine_(speed, 3, {2}, "coin")
obstacles_list[21] = util.stillLine_(speed, 1, nil, "coin")
obstacles_list[25] = util.coinCircle_(speed, 4, 8)
obstacles_list[32] = util.stillText_(speed, 0, 0, "Avoid the spikes", native.systemFont, 1, {0,0,0})
obstacles_list[33] = util.stillLine_(speed, 1, nil, "spike")
obstacles_list[37] = util.stillLine_(speed, 3, {2}, "spike")
obstacles_list[41] = util.stillLine_(speed, 1, nil, "spike")
obstacles_list[47] = util.stillText_(speed, 0, 0, "Hold tap for constant wind", native.systemFont, 1, {0,0,0})


local level_1 =  {
    name = "Test level 1",
    victory = 60,
    obstacles = obstacles_list,
}

return level_1
