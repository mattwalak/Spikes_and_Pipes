-- Temporary file so I can draft my new level building utilities

local CN = require("crazy_numbers")
local util = {}

-- Helpful numbers
local _left = -CN.COL_NUM/2
local _right = CN.COL_NUM/2
local _top = (display.contentHeight/CN.COL_WIDTH)/2
local _bottom = -(display.contentHeight/CN.COL_WIDTH)/2
local _halfSpikeWidth = CN.SPIKE_WIDTH/2
local _halfSpikeHeight = CN.SPIKE_HEIGHT/2

function newCenteredNull()

-- Basic objects: Returns centered null
function newText(x, y, displayText, font, fontSize, color)
function newBasicObject(x, y, rot) -- Any non-moving, pre-defined pattern of display objects