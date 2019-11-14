local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 4000

-- Define obstacles ------------------------------------------------------------

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}

local level_2 =  {
    name = "Test level 2",
    speed = 4,
    victory = 4,
    obstacles = obstacles_list,
}

return level_2