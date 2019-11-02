-- game.lua
-- © Matthew Walak 2019
-- All code controlling the behavior of bubbles

local CN = require("crazy_numbers")
local util = require("util")

local bubble_module = {}
local bubbles = {} -- We will store all active bubbles in this list
local textGroup = {} -- Debug table to store numbers representing groups bubbles belong to
-- bubbles[i] corresponds with textGroup[i]

-- Stores information about where the user touched / Where and how to apply forces
local touch
local touch_location


-- Creates a new bubble and adds it to our list of bubbles
local function newBubble(displayGroup)
    local thisBubble = display.newImageRect("Game/bubble.png", CN.COL_WIDTH, CN.COL_WIDTH)
    displayGroup:insert(thisBubble)
    thisBubble.x = 0
    thisBubble.y = 0
    thisBubble.group = -1
    physics.addBody(thisBubble, "dynamic",{radius=CN.BUBBLE_RADIUS})
    thisBubble.linearDamping = CN.LN_DAMPING;
    thisBubble.type = "bubble"
    table.insert(bubbles, thisBubble)

    -- Debug text for group numbering
    local text = display.newText(displayGroup, "-1", 0, 0, native.systemFont, CN.COL_WIDTH)
    text:setTextColor(0,0,0,255)
    table.insert(textGroup, text)

    return thisBubble
end

-- Listener to spawn an new bubble (Used in intro and menu sequences)
local function onSpawnBubble(event)
    local params = event.source.params;
    local thisBubble = newBubble(params.displayGroup)
    thisBubble.x = params.initPoint.x
    thisBubble.y = params.initPoint.y
    local randomX = ((math.random()-.5)*CN.INTRO_RANDOM_WIDTH) * CN.INTRO_FORCE
    thisBubble:applyLinearImpulse(randomX, CN.INTRO_FORCE, thisBubble.x, thisBubble.y)

    -- Call self again with delay if bubbles still left
    if params.num_bubbles-1 > 0 then
        local tm = timer.performWithDelay(CN.INTRO_DELAY, onSpawnBubble)
        tm.params = {displayGroup=params.displayGroup, num_bubbles=params.num_bubbles-1, initPoint=params.initPoint}
    end
end

-- Reassigns bubble groups based on proximity
local function reassignGroups()
	for i = 1, #bubbles, 1 do
		bubbles[i].group = -1
	end

	-- We can definetely make this algoritm faster... We'll worry about that later
	for i = 1, #bubbles, 1 do
		local thisBubble = bubbles[i]
		thisBubble.group = i
		for j = 1, #bubbles, 1 do
			cmpBubble = bubbles[j]
			if j ~= i then
				local xDist = cmpBubble.x - thisBubble.x
				local yDist = cmpBubble.y - thisBubble.y
				local totalDist = math.sqrt(math.pow(xDist,2) + math.pow(yDist,2))
				if totalDist < CN.BUBBLE_MIN_GROUP_DIST then
					local oldGroup = cmpBubble.group
					-- Flip all other bubbles in this group
					for k = 1, #bubbles, 1 do
						if bubbles[k].group == oldGroup then
							bubbles[k].group = thisBubble.group
						end
					end
				end
			end
		end
	end
end

-- Applies bubble to bubble gravity force
-- Force is proportional to 1/dist^2 and direction is determined by angle between touch and bubble group median
local function applyGravityForce()

	reassignGroups()
    -- Apply gravity force for all (i,j) bubble pairs
    for i = 1, #bubbles, 1 do
        for j = i+1, #bubbles, 1 do
            -- Calculates force applied on bubble1 by bubble2 by distance
            local bubble1 = bubbles[i]
            local bubble2 = bubbles[j]

            local xDist = bubble2.x - bubble1.x
            local yDist = bubble2.y - bubble1.y
            -- Force based on 1/x^2 relationship
            local totalDist = math.sqrt(math.pow(xDist,2) + math.pow(yDist,2))
                
            local xSign -- Preserve direction
            local ySign 
            if xDist > 0 then xSign = 1 else xSign = -1 end
            if yDist > 0 then ySign = 1 else ySign = -1 end

            -- Calculate gravitational forces
            local gx = 0
            local gy = 0
            if xDist ~= 0 then
                gx = CN.GRAVITY*(1/math.pow(totalDist,2))
            end
            if yDist ~= 0 then
                gy = CN.GRAVITY*(1/math.pow(totalDist,2))
            end

            bubble1:applyForce(xSign*gx, ySign*gy, bubble1.x, bubble1.y) -- Apply force to bubble1
            bubble2:applyForce(-xSign*gx, -ySign*gy, bubble2.x, bubble2.y) -- Apply equal but opposite force to bubble2     
        end
    end
end

-- Animates in num_bubbles bubbles (intro style) from (x,y)
function bubble_module.introBubbles(displayGroup, num_bubbles, initPoint)
    local tm = timer.performWithDelay(CN.INTRO_DELAY, onSpawnBubble)
    tm.params = {displayGroup=displayGroup, num_bubbles=num_bubbles, initPoint=initPoint}
end

-- Apply touch forces
local function applyTouchForce()
    if not touch then return end

    -- Calculates force applied on each bubble in turn
    for i = 1, #bubbles, 1 do
        local thisBubble = bubbles[i]
        local xDist = thisBubble.x - touch_location.x
        local yDist = thisBubble.y - touch_location.y
        -- Force based on 1/x^2 relationship
        local totalDist = math.sqrt(math.pow(xDist,2) + math.pow(yDist,2))
                    
        local xSign -- Preserve direction
        local ySign 
        if xDist > 0 then xSign = 1 else xSign = -1 end
        if yDist > 0 then ySign = 1 else ySign = -1 end

        -- Calculate gravitational forces
        local gx = 0
        local gy = 0
        if xDist ~= 0 then
            gx = CN.TOUCH_FORCE_FACTOR*(1/math.pow(totalDist,2))
        end
        if yDist ~= 0 then
            gy = CN.TOUCH_FORCE_FACTOR*(1/math.pow(totalDist,2))
        end

        thisBubble:applyForce(xSign*gx, ySign*gy, thisBubble.x, thisBubble.y)
    end
      
end

-- Updates group numbers and positions
function bubble_module.updateNumText()
	reassignGroups()
	for i = 1, #bubbles, 1 do
		textGroup[i].text = bubbles[i].group
		textGroup[i].x = bubbles[i].x
		textGroup[i].y = bubbles[i].y
	end
end

-- Applies all forces to bubbles
function bubble_module.applyForce()
    applyGravityForce()
    applyTouchForce()
end

-- Bubble touch handler -> Called when the game area recieves a touch
function bubble_module.onTouch(event)
    if(event.phase == "began") then
        touch = true
        touch_location = util.newPoint(event.x, event.y)
        --print("began at x = "..touch_location.x..", y = "..touch_location.y)
    elseif(event.phase == "ended") then
        touch = false
        --print("ended at x = "..touch_location.x..", y = "..touch_location.y)
    elseif(event.phase == "moved") then
        touch_location = util.newPoint(event.x, event.y)
        --print("moved at x = "..touch_location.x..", y = "..touch_location.y)
    elseif(event.phase == "cancelled") then
        touch = false
    end
end

return bubble_module
