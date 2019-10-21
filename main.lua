-- main.lua
-- © Matthew Walak 2019
-- Starting point to launch Spikes and Pipes

-- CN = Crazy Numbers!!! (Constants)
local CN = require "crazy_numbers"


--[[
-- Create a nice white background for y'all
local bg = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
bg:setFillColor(1,1,1)

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

--[[local displayGroup = {}
local obstacleData = {}

local function destroy(object)
	if object == nil then
		return
	end
	destroy(object.object)
	print("setting name: "..object.name)
	transition.cancel(object)

end

local function t(object)
	if object.destroyed then
		return
	end

	print(object.name..": "..object.x)

	if object.x > 12 then
		destroy(object)
		return
	end

	local newX = object.x+1
	transition.to(object, {x=newX, onComplete=t, time=1000})

end

local function newObject()
	local small = {name="small",x = 0}
	local big = {object=small, x=10, name="big"}
	t(small)
	t(big)
end

newObject()



-----------------------------------
local function printTest(object)
	print(object.name)
	transition.to(object, {x=0, onComplete=printTest, time=1000})
end

local function printTest2(object)
	print(object.name)
	transition.to(object, {x=0, onComplete=printTest, time=1000})
end

local function test()
	local object = {name="steve", x=0}
	printTest(object)
	object.name = "butts"
end
]]--
