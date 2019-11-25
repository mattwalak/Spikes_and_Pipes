local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 10000

-- Define obstacles ------------------------------------------------------------
local null_1A = {}
null_1A.type = "null"
null_1A.name = "1A"
null_1A.position_path = {util.newPoint(-6.5, 0), util.newPoint(6.5, 0)}
null_1A.rotation_path = {0,180}
null_1A.transition_time = {5000, 5000}
null_1A.position_interpolation = easing.inSine
null_1A.rotation_interpolation = easing.linear
null_1A.on_complete = "loop"
null_1A.first_frame = 1
null_1A.children = util.newSpike(0,0, true)

obstacle_1 = util.newParentObstacle(speed, "1P")
obstacle_1.children = {null_1A}

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[2] = obstacle_1

local level_2 =  {
    name = "Test level 2",
    speed = 10,
    victory = 10,
    obstacles = obstacles_list,
}

return level_2
