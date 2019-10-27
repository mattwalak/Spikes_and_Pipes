local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 4000


-- Define obstacles ------------------------------------------------------------
local parent_1 = util.newParentObstacle(speed, "1P")
local null_1A = {
    name = "1A",
    position_path = {util.newPoint(-5, 0), util.newPoint(5, 0)},
    rotation_path = {0,0},
    transition_time = {1000, 1000},
    position_interpolation = easing.inSine,
    rotation_interpolation = easing.linear,
    on_complete = "loop",
    first_frame = 1,
    children = nil
}
local displayObject_1A = {
    type = "black_square",
    x = 0,
    y = 0,
    rotation = 0,
    ancestry = {parent_1, null_1A}
}
parent_1.children = {null_1A}
local obstacle_1 ={
    null_objects = {parent_1, null_1A},
    display_objects = {displayObject_1A}
}


local parent_2 = util.newParentObstacle(speed, "2P")
local null_2A = {
    name = "2B",
    position_path = {util.newPoint(1, 1), util.newPoint(-1, 1), util.newPoint(-1, 0), util.newPoint(1, 0)},
    rotation_path = {0,0},
    transition_time = {50, 50, 50, 50},
    position_interpolation = easing.inSine,
    rotation_interpolation = easing.linear,
    on_complete = "loop",
    first_frame = 1,
    children = nil
}
local displayObject_2A = {
    type = "black_square",
    x = 0,
    y = 0,
    rotation = 0,
    ancestry = {parent_2, null_2A}
}
parent_2.children = {null_2A}
local obstacle_2 ={
    null_objects = {parent_2, null_2A},
    display_objects = {displayObject_2A}
}
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
