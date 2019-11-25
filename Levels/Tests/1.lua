local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------


--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[3] = util.stillSpikeLine_(speed, 1)
obstacles_list[10] = util.stillSpikeLine_(speed, 3, {2})
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
