local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------
local obstacle_1 = util.newParentObstacle(speed, "1P")

local s = util.newPoint(-12, 0)
local e = util.newPoint(12, 0)
local lineModel = util.newLineModel(s, e, 2, 4000)
local squareModel = util.new4SquareModel(util.newPoint(0,0), 4, 4000)
local square = util.wrapLoopPath(squareModel, util.newSpikeList(4, true))
local squareList = util.list(square, 2)

local combine = util.wrapLoopPath(lineModel, squareList)

util.tableExtend(obstacle_1.children, combine)

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[1] = obstacle_1

local level_1 =  {
    name = "Test level 1",
    victory = 10,
    obstacles = obstacles_list,
}

return level_1
