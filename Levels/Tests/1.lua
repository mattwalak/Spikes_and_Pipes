local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------
local null_1A = {}



--[[local square1 = util.new4Square(util.newPoint(0,0), 4, 4000, true)
square1 = util.wrapLoopPath(square1, util.spikeList(4))
local square2 = util.new4Square(util.newPoint(0,0), 4, 4000, true)
square2 = util.wrapLoopPath(square2, util.spikeList(4))]]

local black1 = util.newBlackSquare(0,0,0)
local black2 = util.newBlackSquare(0,0,0)

local s = util.newPoint(-6.5, 0)
local e = util.newPoint(6.5, 0)
local nullModel = util.newSpikeLine(s, e, 2, 4000, true)
local combine = util.wrapLoopPath(nullModel, {black1, black2, nil})
print("COMBINE HAS: "..#combine)

local obstacle_1 = util.newParentObstacle(speed, "1P")
--util.tableExtend(obstacle_1.children, combine)
--print("OBSTACLE 1 HAS "..#obstacle_1.children.." children")
util.tableExtend(obstacle_1.children, util.newBlackSquare(0,0,0))


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
