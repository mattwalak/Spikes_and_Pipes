-- crazy_numbers.lua
-- © Matthew Walak 2019
-- All the important constants and things

local COL_NUM = 10
local COL_WIDTH = display.contentWidth/COL_NUM

local crazy_numbers = {
	-- Display
	COL_NUM = COL_NUM,
	COL_WIDTH = COL_WIDTH,

	-- Physics
	LN_DAMPING = 1,
	GRAVITY = 3.5,
	TOUCH_FORCE_FACTOR = 225,

	-- Bubble
	BUBBLE_RADIUS = (4/5)*(COL_WIDTH/2),
	BUBBLE_MIN_GROUP_DIST = 2*COL_WIDTH,
	EDGE_FORCE_FACTOR = .5,
	EDGE_FORCE_DIST = 2*COL_WIDTH,

	-- Intro
	INTRO_DELAY = 80,
	INTRO_FORCE = -1,
	INTRO_RANDOM_WIDTH = .25,
}

return crazy_numbers
