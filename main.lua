-- main.lua
-- © Matthew Walak 2019
-- Starting point to launch Spikes and Pipes

-- CN = Crazy Numbers!!! (Constants)
local CN = require "crazy_numbers"

-- Create a nice white background for y'all
local bg = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
bg:setFillColor(1,1,1)

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