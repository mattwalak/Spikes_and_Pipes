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
	GRAVITY = 8000,
	TOUCH_FORCE_FACTOR = 100000,


	-- Intro
	INTRO_DELAY = 80,
	INTRO_FORCE = -2,
	INTRO_RANDOM_WIDTH = .25,
}

return crazy_numbers
