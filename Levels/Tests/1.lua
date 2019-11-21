local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------
local obstacle_1 = util.newParentObstacle(speec, "1P")
util.tableExtend(obstacle_1.children, util.newVerticalSpike(0,0))


local obstacle_2 = util.newParentObstacle(speed, "2P")
local spikeLine = util.newSpikeLine(-6, 0, 6, 0, 4, 8000, true)
util.tableExtend(obstacle_2.children, spikeLine)

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[1] = obstacle_1
obstacles_list[3] = obstacle_2

local level_1 =  {
    name = "Test level 1",
    victory = 10,
    obstacles = obstacles_list,
}

return level_1
