local CN = require("crazy_numbers")
local util = require("util")


-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 4000

-- Define obstacles ------------------------------------------------------------
-- Obstacle 1
local obstacle_1 = util.newParentObstacle(speed)
local obstacle_1_child = {
    name = "Black Square",
    path = {0,0},
    animation_options = {
      time = {4000},
      time_interpolation = nil,
      rotation = {0},
      rotation_interpolation = nil
    },
    object = "black_square",
    on_complete = "stop",
    first_frame = 1
}
obstacle_1.object = obstacle_1_child

-- Obstacle 2
local obstacle_2 = util.newParentObstacle(speed)
local obstacle_2_child = {
    name = "Black Square 2",
    path = {-1,0,1,0},
    animation_options = {
      time = {1000},
      time_interpolation = nil,
      rotation = {0},
      rotation_interpolation = nil
    },
    object = "black_square",
    on_complete = "stop",
    first_frame = 1
}
obstacle_2.object = obstacle_2_child
--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
--obstacles_list[2] = obstacle_1
obstacles_list[4] = obstacle_2

local level_1 =  {
    name = "Test level 1",
    speed = 4,
    victory = 10,
    obstacles = obstacles_list,
}

return level_1
