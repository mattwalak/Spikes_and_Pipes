-- game.lua
-- © Matthew Walak 2019
-- All code controlling the behavior of bubbles

local CN = require("crazy_numbers")
local util = require("util")

local bubble_module = {}
local bubbles = {} -- We will store all active bubbles in this list
local textGroup = {} -- Debug table to store numbers representing groups bubbles belong to
                        -- bubbles[i] corresponds with textGroup[i]
local drawCOM = {} -- Debug table to store center of mass display data
local comTable = {} -- List of (x,y) pairs describing the center of mass of each bubble clump

-- Stores information about where the user touched / Where and how to apply forces
local touch
local touch_velocity
local touch_location
local touch_last_location
local touch_last_time

-- Creates a new bubbleClump
local function newBubbleClump()
    local clump = {}
    clump.bubbles = {}
    clump.com = util.newPoint(0,0)
    return clump
end

-- Creates a new bubble and adds it to our list of bubbles
local function newBubble(displayGroup)
    local thisBubble = display.newImageRect("Game/bubble.png", CN.COL_WIDTH, CN.COL_WIDTH)
    displayGroup:insert(thisBubble)
    thisBubble.x = 0
    thisBubble.y = 0
    thisBubble.group = -1
    physics.addBody(thisBubble, "dynamic",{radius=CN.BUBBLE_RADIUS, desity=1.0})
    thisBubble.linearDamping = CN.LN_DAMPING
    thisBubble.type = "bubble"
    table.insert(bubbles, thisBubble)
    --print("mass = "..thisBubble.mass)

    -- Debug text for group numbering
    --local text = display.newText(displayGroup, "-1", 0, 0, native.systemFont, CN.COL_WIDTH)
    --text:setTextColor(0,0,0,255)
    --table.insert(textGroup, text)

    return thisBubble
end

-- Listener to spawn an new bubble (Used in intro and menu sequences)
local function onSpawnBubble(event)
    local params = event.source.params
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
			if (j ~= i) and (bubbles[j].group ~= -1) and (bubbles[j].group ~= thisBubble.group) then
                local cmpBubble = bubbles[j]
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

    -- recalculate center of mass
    local clumpSizes = {}
    comTable = {}
    for i = 1, #bubbles, 1 do
        table.insert(comTable, nil)
        table.insert(clumpSizes, 0)
    end

    for i = 1, #bubbles, 1 do
        local thisBubble = bubbles[i];
        local groupNum = thisBubble.group
        if not comTable[groupNum] then
            comTable[groupNum] = util.newPoint(0,0)
        end

        local xTotal = comTable[groupNum].x * clumpSizes[groupNum]
        local yTotal = comTable[groupNum].y * clumpSizes[groupNum]

        clumpSizes[groupNum] = clumpSizes[groupNum] + 1
        xTotal = xTotal + thisBubble.x
        yTotal = yTotal + thisBubble.y
        comTable[groupNum].x = xTotal / clumpSizes[groupNum]
        comTable[groupNum].y = yTotal / clumpSizes[groupNum]
    end

    -- Update drawCOM (Debug only)
    --[[
    for i = 1, #bubbles, 1 do
        if drawCOM[i] then
            drawCOM[i]:removeSelf()
            drawCOM[i] = nil
        end

        if comTable[i] then
            drawCOM[i] = display.newRect(comTable[i].x, comTable[i].y,
                CN.COL_WIDTH/2, CN.COL_WIDTH/2)
            drawCOM[i]:setFillColor(.5, .5, .5)
        end
    end]]

end

-- Applies bubble to bubble gravity force
-- Force is proportional to 1/dist^2 and direction is determined by angle between touch and bubble group median
local function applyGravityForce()

    -- Apply gravity force for all (i,j) bubble pairs
    for i = 1, #bubbles, 1 do
        local thisBubble = bubbles[i]
        local groupCOM = comTable[thisBubble.group]
        local xDist = groupCOM.x - thisBubble.x
        local yDist = groupCOM.y - thisBubble.y
        local totalDist = math.sqrt(math.pow(xDist,2) + math.pow(yDist,2))

        -- Preserve direction
        local xSign
        local ySign
        if xDist > 0 then xSign = 1 else xSign = -1 end
        if yDist > 0 then ySign = 1 else ySign = -1 end

        -- Calculate gravitational forces
        local gx = 0
        local gy = 0
        if xDist ~= 0 then
            gx = CN.GRAVITY*(totalDist/1000)--*(1/math.pow(totalDist,2))
        end
        if yDist ~= 0 then
            gy = CN.GRAVITY*(totalDist/1000)--*(1/math.pow(totalDist,2))
        end

        thisBubble:applyForce(xSign*gx, ySign*gy, thisBubble.x, thisBubble.y) -- Apply force to bubble1



        --[[
        -- METHOD TO MIMIC REAL GRAVITY (BUT KIND OF LAME)
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
        end]]
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
    if #bubbles == 0 then return end

    -- Finds closest group and applies the same force to all bubbles in that groups
    -- There is at least one bubble, so there is at least 1 group to apply force to
    local closestDist
    local closestGroup
    local closestAngle
    local direction
    for i = 1, #bubbles, 1 do
        if comTable[i] then
            local xDist = comTable[i].x - touch_location.x
            local yDist = comTable[i].y - touch_location.y
            local totalDist = math.sqrt(math.pow(xDist,2) + math.pow(yDist,2))
            if not closestDist then
                closestDist = totalDist
                closestGroup = i
                closestAngle = math.atan(yDist/xDist)
                if xDist < 0 then direction = -1 else direction = 1 end
            elseif math.abs(totalDist) < math.abs(closestDist) then
                closestDist = totalDist
                closestGroup = i
                closestAngle = math.atan(yDist/xDist)
                if xDist < 0 then direction = -1 else direction = 1 end
            end
        end
    end

    
    -- Apply force to bubbles in that group
    --local force = CN.TOUCH_FORCE_FACTOR*(1/math.pow(closestDist,1))
    local maxFactor = 0
    local minFactor = 100
    for i = 1, #bubbles, 1 do
        local thisBubble = bubbles[i]
        if thisBubble.group == closestGroup then
            local xDist = thisBubble.x - touch_location.x
            local yDist = thisBubble.y - touch_location.y
            local bubbleDist = math.sqrt(math.pow(xDist,2) + math.pow(yDist,2))
            local angle = math.atan(yDist/xDist)

            -- Push method
            -- local force = CN.TOUCH_FORCE_FACTOR*(1/math.pow(bubbleDist,1))

            -- Pull method
            -- local force = -CN.TOUCH_PULL_FACTOR

            -- Pull based on velocity
            local xforce = CN.TOUCH_VELOCITY_FACTOR*touch_velocity.x
            local yforce = CN.TOUCH_VELOCITY_FACTOR*touch_velocity.y

            -- A little bit of variation based on distance
            --[[
            local xFactor = CN.INTERCEPT + (1/math.pow(xDist,1)) * CN.INVERSE_VARIATION
            local yFactor = CN.INTERCEPT + (1/math.pow(yDist,1)) * CN.INVERSE_VARIATION

            xforce = xforce * (1/math.pow(bubbleDist,1)) * CN.INVERSE_VARIATION
            yforce = yforce * (1/math.pow(bubbleDist,1)) * CN.INVERSE_VARIATION

            local thisFactor = (1/math.pow(bubbleDist,1)) * CN.INVERSE_VARIATION
            if thisFactor > maxFactor then maxFactor = thisFactor end
            if thisFactor < minFactor then minFactor = thisFactor end
            ]]

            --thisBubble:applyForce(force*direction*math.cos(closestAngle), force*direction*math.sin(closestAngle), thisBubble.x, thisBubble.y)
            thisBubble:applyForce(xforce, yforce, thisBubble.x, thisBubble.y)
        end
    end

    -- Calculates force applied on each bubble in turn
    --[[
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
    end]]

end

-- Applys force pushing bubbles away from the edge
local function applyEdgeForce()
    for i = 1, #bubbles, 1 do
        local thisBubble = bubbles[i]
        if thisBubble.x < CN.EDGE_FORCE_DIST then
            thisBubble:applyForce(CN.EDGE_FORCE_FACTOR, 0, thisBubble.x, thisBubble.y)
        end
        if thisBubble.x > (display.contentWidth - CN.EDGE_FORCE_DIST) then
            thisBubble:applyForce(-CN.EDGE_FORCE_FACTOR, 0, thisBubble.x, thisBubble.y)
        end

        if thisBubble.y < CN.EDGE_FORCE_DIST then
            thisBubble:applyForce(0, CN.EDGE_FORCE_FACTOR, thisBubble.x, thisBubble.y)
        end
        if thisBubble.y > (display.contentHeight - CN.EDGE_FORCE_DIST) then
            thisBubble:applyForce(0, -CN.EDGE_FORCE_FACTOR, thisBubble.x, thisBubble.y)
        end

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

-- Updates velocity of touch
function updateTouchData()
    local time = system.getTimer()
    if not touch_last_location then
        touch_velocity = util.newPoint(0,0)
    else
        local dt = time - touch_last_time
        local vx = touch_location.x - touch_last_location.x
        vx = vx/dt
        local vy = touch_location.y - touch_last_location.y
        vy = vy/dt
        touch_velocity.x = vx
        touch_velocity.y = vy
    end
    touch_last_location = touch_location
    touch_last_time = time
end

-- Applies all forces to bubbles
function bubble_module.applyForce()
    reassignGroups()
    applyGravityForce()
    if touch then
        updateTouchData()
        applyTouchForce()
    end
    
    applyEdgeForce()
end

-- Gets rid of all the bubbles
function bubble_module.destroyBubbles()
    for i = 1, #bubbles, 1 do
        bubbles[i]:removeSelf()
        bubbles[i] = nil
        if textGroup[i] then
            textGroup[i]:removeSelf()
            textGroup[i] = nil
        end
    end

    -- I'm like 80% sure garbanzo collection will take care of these for me
    bubbles = {}
    textGroup = {}
    drawCOM = {}
    comTable = {}
end

-- Pops a bubble :(
function bubble_module.popBubble(thisBubble)
    for i = 1, #bubbles, 1 do
        if thisBubble == bubbles[i] then
            thisBubble = table.remove(bubbles, i)
            thisBubble:removeSelf()
            thisBubble = nil
            return
        end
    end
end

-- Bubble touch handler -> Called when the game area recieves a touch
function bubble_module.onTouch(event)
    if(event.phase == "began") then
        touch_location = util.newPoint(event.x, event.y)
        touch_last_location = nil
        touch = true
    elseif(event.phase == "ended") then
        touch = false
    elseif(event.phase == "moved") then
        touch_location = util.newPoint(event.x, event.y)
    elseif(event.phase == "cancelled") then
        touch = false
    end
end



-- Returns number of bubbles left
function bubble_module.numBubbles()
    return #bubbles
end

return bubble_module
