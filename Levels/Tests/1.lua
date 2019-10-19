local CN = require("crazy_numbers")
local util = require("util")
local MIDDLE_Y = display.contentHeight/CN.COL_WIDTH/2
local MIDDLE_X = display.contentWidth/CN.COL_WIDTH/2



-- SPEED OF ALL OBSTACLES (Number of seconds from top to bottom)
local speed = 4

-- Define obstacles ------------------------------------------------------------
-- Obstacle 1
local obstacle_1 = util.newParentObstacle(speed)
local obstacle_1_child = {
    path = {0,0},
    animation_options = {
      time = {400},
      time_interpolation = nil,
      rotation = {0},
      rotation_interpolation = nil
    },
    object = "black_square",
    on_complete = "stop"
}
obstacle_1.object = obstacle_1_child

-- Obstacle 2
local obstacle_2 = util.newParentObstacle(speed)
local obstacle_2_child = {
    path = {0,0},
    animation_options = {
      time = {400},
      time_interpolation = nil,
      rotation = {0},
      rotation_interpolation = nil
    },
    object = "probably your grandma",
    on_complete = "stop"
}
obstacle_2.object = obstacle_2_child
--------------------------------------------------------------------------------


-- Define pairs
local obstacles_list = {}
obstacles_list[2] = obstacle_1
obstacles_list[4] = obstacle_2

local level_1 =  {
    name = "Test level 1",
    speed = 4,
    victory = 10,
    obstacles = obstacles_list,
}

return level_1
