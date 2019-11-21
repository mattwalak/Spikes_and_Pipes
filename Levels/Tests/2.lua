local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 2000

-- Define obstacles ------------------------------------------------------------
local null_1A = {}
local displayObject_1A = {}

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
util.tableExtend(null_1A.children, util.newHorizontalSpike(0,0))



obstacle_1 = util.newParentObstacle(speed, "1P")
obstacle_1.children = {null_1A}

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[2] = obstacle_1
obstacles_list[3] = util.deepcopy(obstacle_1)
obstacles_list[4] = util.deepcopy(obstacle_1)
obstacles_list[5] = util.deepcopy(obstacle_1)
obstacles_list[6] = util.deepcopy(obstacle_1)
obstacles_list[7] = util.deepcopy(obstacle_1)
obstacles_list[8] = util.deepcopy(obstacle_1)

local level_2 =  {
    name = "Test level 2",
    speed = 10,
    victory = 10,
    obstacles = obstacles_list,
}

return level_2
