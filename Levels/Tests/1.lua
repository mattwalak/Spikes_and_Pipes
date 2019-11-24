local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------
local null_1A = {}

local obstacle_1 = util.newParentObstacle(speed, "1P")
obstacle_1.children = {util.newCoin(0,0)}

--[[
local s = util.newPoint(-6.5, -2)
local e = util.newPoint(6.5, 2)
util.tableExtend(obstacle_1.children, util.newSpikeLine(s,e,2,2000,true))
e = util.newPoint(-6.5, -8)
s = util.newPoint(6.5, -12)
util.tableExtend(obstacle_1.children, util.newSpikeLine(s,e,2,2000,true))
s = util.newPoint(-6.5, -8-10)
e = util.newPoint(6.5, -12-10)
util.tableExtend(obstacle_1.children, util.newSpikeLine(s,e,2,2000,true))
e = util.newPoint(-6.5, -8-10-10)
s = util.newPoint(6.5, -12-10-10)
util.tableExtend(obstacle_1.children, util.newSpikeLine(s,e,2,2000,true))
]]

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
