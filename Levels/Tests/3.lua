local CN = require("crazy_numbers")
local lb = require("level_builder")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000

-- Define pairs
local obstacles_list = {}
obstacles_list[1] = lb.obstacle(speed, 3)
obstacles_list[12] = lb.obstacle(speed, 8)
obstacles_list[23] = lb.obstacle(speed, 10)
obstacles_list[34] = lb.obstacle(speed, 13)

local level_3 =  {
    name = "Test level 3",
    speed = 4,
    victory = 100,
    obstacles = obstacles_list,
    startScore = 0
}

return level_3
