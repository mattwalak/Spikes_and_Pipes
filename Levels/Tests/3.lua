local CN = require("crazy_numbers")
local lb = require("level_builder")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000

-- Define pairs
local obstacles_list = {}
obstacles_list[1] = lb.threeFans_(speed)

local level_3 =  {
    name = "Test level 3",
    speed = 4,
    victory = 20,
    obstacles = obstacles_list,
}

return level_3
