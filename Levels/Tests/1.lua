local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 4000


-- Define obstacles ------------------------------------------------------------
local parent_1 = util.newParentObstacle(speed)
local null_1A = {
    name = "Parent",
    position_path = {util.newPoint(-5, 0), util.newPoint(5, 0)},
    rotation_path = {0,0},
    transition_time = {1000, 1000},
    keyframe_interpolation = easing.linear,
    on_complete = "loop",
    first_frame = 1,
}
local displayObject_1 = {
    type = "black_square",
    x = 0,
    y = 0,
    rotation = 0,
    ancestry = {parent_1, null_1A}
}
local obstacle_1 ={
    null_objects = {parent_1, null_1A},
    display_objects = {displayObject_1}
}

--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacle_list[1] = obstacle_1

local level_1 =  {
    name = "Test level 1",
    victory = 10,
    obstacles = obstacles_list,
}

return level_1
