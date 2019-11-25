local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000

-- Define obstacles ------------------------------------------------------------
local s1 = util.newPoint(-6.5, 0)
local e1 = util.newPoint(6.5, 0)

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[1] = util.spikeLine_(speed, s1, e1, 1, 4000)

local level_2 =  {
    name = "Test level 2",
    speed = 10,
    victory = 10,
    obstacles = obstacles_list,
}

return level_2
