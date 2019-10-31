-- main.lua
-- © Matthew Walak 2019
-- Starting point to launch Spikes and Pipes

-- CN = Crazy Numbers!!! (Constants)
local CN = require "crazy_numbers"

print("content width: "..display.contentWidth)

-- Create a nice white background for y'all
local bg = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
bg:setFillColor(1,1,1)

--[[
-- Sets up a checkered background
local yMax = math.ceil(display.contentHeight/CN.COL_WIDTH)
print("x: 10, y: "..yMax)
for y = 0, yMax, 1 do
	for x = 0, CN.COL_NUM, 1 do
		local rect = display.newRect((x*CN.COL_WIDTH) + CN.COL_WIDTH/2, (y*CN.COL_WIDTH) + CN.COL_WIDTH/2,
			CN.COL_WIDTH, CN.COL_WIDTH)
		if(((x+y)%2) == 0) then
			rect:setFillColor(.5, .5, .5)
		else
			rect:setFillColor(1,1,1)
		end
	end
end]]

local composer = require("composer")

--Hide status bar
display.setStatusBar(display.HiddenStatusBar)

-- Reserve channel 1 for background music
audio.reserveChannels(1)

-- Reduce the overall volume of the channel
audio.setVolume(0.5, {channel=1})

--Go to the menu screen
composer.gotoScene("title_screen")

--End of file