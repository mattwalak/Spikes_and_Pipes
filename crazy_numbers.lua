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


	-- Intro
	INTRO_DELAY = 100,
	INTRO_FORCE = -1,
}

return crazy_numbers
