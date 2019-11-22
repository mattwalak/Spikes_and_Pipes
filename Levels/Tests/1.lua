local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000


-- Define obstacles ------------------------------------------------------------
local null_1A = {}

local obstacle_1 = util.newParentObstacle(speed, "1P")
local s = util.newPoint(-6.5, 1)
local e = util.newPoint(6.5, -1)
local things = util.newSpikeLine(s,e,3,2000,true)
print("HERE")
util.tableExtend(obstacle_1.children, things)
print("DONE")

--[[obstacle_1.children = {null_1A}
null_1A.type = "null"
null_1A.name = "1A"
null_1A.position_path = {util.newPoint(-6, 0), util.newPoint(6, 0)}
null_1A.rotation_path = {0,0}
null_1A.transition_time = {5000, 5000}
null_1A.position_interpolation = easing.inSine
null_1A.rotation_interpolation = easing.linear
null_1A.on_complete = "loop"
null_1A.first_frame = 1
null_1A.children = {}
util.tableExtend(null_1A.children, util.newHorizontalSpike(0,0))]]--


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
