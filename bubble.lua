-- game.lua
-- © Matthew Walak 2019
-- All code controlling the behavior of bubbles

local CN = require("crazy_numbers")
local util = require("util")

local bubble_module = {}
local bubbles = {} -- We will store all active bubbles in this list

-- Creates a new bubble and adds it to our list of bubbles
local function newBubble(displayGroup)
    local thisBubble = display.newImageRect("Game/bubble.png", CN.COL_WIDTH, CN.COL_WIDTH)
    displayGroup:insert(thisBubble)
    thisBubble.x = 0
    thisBubble.y = 0
    physics.addBody(thisBubble, "dynamic",{radius=CN.COL_WIDTH/2})
    thisBubble.linearDamping = CN.LN_DAMPING;
    thisBubble.type = "bubble"
    table.insert(bubbles, thisBubble)

    return thisBubble
end

-- Listener to spawn an new bubble (Used in intro and menu sequences)
local function onSpawnBubble(event)
    local params = event.source.params;
    local thisBubble = newBubble(params.displayGroup)
    thisBubble.x = params.initPoint.x
    thisBubble.y = params.initPoint.y
    local randomX = ((math.random()-.5)/2) * CN.INTRO_FORCE
    thisBubble:applyLinearImpulse(.001, CN.INTRO_FORCE, thisBubble.x, thisBubble.y)

    -- Call self again with delay if bubbles still left
    if params.num_bubbles-1 > 0 then
        local tm = timer.performWithDelay(CN.INTRO_DELAY, onSpawnBubble)
        tm.params = {displayGroup=params.displayGroup, num_bubbles=params.num_bubbles-1, initPoint=params.initPoint}
    end
end


local function applyGravity()
    -- Itterate through all (i,j) pairs and calculate/apply gravity force
    for i = 1, #bubbles, 1 do
        for j = i+1, #bubbles, 1 do
            local xDist = bubbles[i].x - bubbles[j].x
            local yDist = bubbles[i].y - bubbles[j].y
            local xSign -- Preserve direction
            local ySign 
            if xDist > 0 then xSign = 1 else xSign = -1 end
            if yDist > 0 then ySign = 1 else ySign = -1 end

            -- Temp non 1/x^2 solution
            if xDist < CN.COL_WIDTH then xSign = 0 else end
            if yDist < CN.COL_WIDTH then ySign = 0 else end

            local gx = CN.GRAVITY*(1/xDist^2)
            local gy = CN.GRAVITY*(1/yDist^2)
            print("gx = "..gx..", gy = "..gy)


            bubbles[i]:applyForce(xSign*gx, ySign*gy, bubbles[i].x, bubbles[i].y)
            bubbles[j]:applyForce(-xSign*gx, -ySign*gy, bubbles[j].x, bubbles[j].y)
        end
    end

end

-- Animates in num_bubbles bubbles (intro style) from (x,y)
function bubble_module.introBubbles(displayGroup, num_bubbles, initPoint)
    local tm = timer.performWithDelay(CN.INTRO_DELAY, onSpawnBubble)
    tm.params = {displayGroup=displayGroup, num_bubbles=num_bubbles, initPoint=initPoint}
end

-- Applies all forces to bubbles
function bubble_module.applyForce()
    applyGravity()

end

return bubble_module
