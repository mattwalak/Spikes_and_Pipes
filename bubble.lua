-- game.lua
-- © Matthew Walak 2019
-- All code controlling the behavior of bubbles

local CN = require("crazy_numbers")

local bubble_module = {}
local bubbles = {} -- We will store all active bubbles in this list

-- Creates a new bubble and adds it to our list of bubbles
local function newBubble(displayGroup)
    local thisBubble = display.newImageRect("Game/bubble.png", CN.COL_WIDTH, CN.COL_WIDTH)
    displayGroup:insert(thisBubble)
    thisBubble.x = 0
    thisBubble.y = 0
    physics.addBody(thisBubble, "dynamic", {radius=CN.COL_WIDTH, density=1.0, bounce=0.1})
    table.insert(bubbles, thisBubble)
    return thisBubble
end

-- Animates in num_bubbles bubbles (intro style) from (x,y)
function bubble_module.introBubbles(displayGroup, x, y, num_bubbles)
    for i = 1, num_bubbles, 1 do
        local thisBubble = newBubble(displayGroup)
        thisBubble.x = x
        thisBubble.y = y
    end
end

return bubble_module
