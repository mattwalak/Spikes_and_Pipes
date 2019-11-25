local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------


--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[1] = util.smallSquareLine_(speed, 4)
obstacles_list[2] = util.simpleMiddleSpike_(speed)

local level_1 =  {
    name = "Test level 1",
    victory = 10,
    obstacles = obstacles_list,
}

return level_1
