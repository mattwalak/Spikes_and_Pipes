-- game.lua
-- © Matthew Walak 2019
-- Where you actually play a level!!!


local levels = require("levels")
local util = require("util")
local CN = require ("crazy_numbers")
local composer = require( "composer" )
local bubble = require("bubble")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize physics
local physics = require("physics")

-- Define display groups
local bubbleGroup
local obstacleGroup
local backgroundGroup
local uiGroup

-- Define game loop
local slow_gameLoopTimer
local fast_gameLoopTimer

-- Define important gameplay variables
local score -- Same as height within the level
local activeDisplayObjects = {} -- All visible blocks, spikes, and powerups
local activeNullObjects = {} -- All active Null objects

-- Define variable for level data
local level_data

-- ui elements
local scoreText

-- Removes everything from

-- Removes all nill nulls from the active nulls table
local function cleanUpNulls()

end

-- Stops all null object transitions and sets them to nil
local function stopNulls()
    for i = 1, #activeNullObjects, 1 do
        transition.cancel(activeNullObjects[i])
        activeNullObjects[i] = nil -- Should probably remove them from the table... maybe?
    end
end

-- Stops all transitions and destroys a null object and its children (And grandchildren)
local function destroyNull(thisNull)
	if not thisNull then -- thisNull was destroyed earlier
		return
	end

	print("destroying name: "..thisNull.name)
    transition.cancel(thisNull) -- Just changed this from deleting by tag/name... Check to see if you can/should eliminate tagging transitions
    if thisNull.children then
    	for i = 0, #thisNull.children, 1 do
    		destroyNull(thisNull.children[i])
    	end
    end

    util.removeFromList(activeNullObjects, thisNull)

    thisNull = nil  -- DisplayObjects know if one of their parents is nill (They will delete themselves)
end

-- Transitions a null object from current_frame to current_frame + 1
local function keyframeNull(thisNull)
    local num_frames = #thisNull.position_path

    -- Calculate current frame accounting for overflow
    local current_frame = ( ((thisNull.first_frame - 1) + thisNull.frame_counter) % num_frames ) + 1

    -- Number of times we have completed the full animation
    -- (If > 1, we are currently at first frame ie. cycle is already complete)
    local revolutions = thisNull.frame_counter/num_frames
    if(revolutions > 0) then
        if(thisNull.on_complete == "destroy") then
        	destroyNull(thisNull)
            return
        elseif(thisNull.on_complete == "stop") then
            return -- Do not start on the next transition
        elseif(thisNull.on_complete == "loop") then
            -- Do nothing
        end
    end

    -- Update frame count (Accounting for overflow) and perform transitions
    local next_frame = (current_frame % num_frames) + 1
    thisNull.frame_counter = thisNull.frame_counter + 1
    local transition_time = thisNull.transition_time[next_frame]
    local next_x = thisNull.position_path[next_frame].x * CN.COL_WIDTH
    local next_y = thisNull.position_path[next_frame].y * CN.COL_WIDTH
    local next_rotation = thisNull.rotation_path[next_frame]

    -- To ensure transitions start at the same time, only the position transition
    -- causes the next transition to be called
    transition.to(thisNull, {
        time = transition_time,
        x = next_x,
        y = next_y,
        transition = thisNull.position_interpolation,
        tag = thisNull.name,
        onComplete = keyframeNull
    })

    transition.to(thisNull, {
        time = transition_time,
        rotation = next_rotation,
        tag = thisNull.name,
        transition = thisNull.rotation_interpolation
    })
end

-- Repositions a display object based on its ancestry
-- Depth indicates how deep we are
-- Returns -1 if we remove an element, 0 otherwise <-- THIS IS BAD AND TEMPORARY
local function reposition(displayObject)
	local x_offset = 0
	local y_offset = 0
	local rotation_offset = 0
	local ancestry = displayObject.ancestry
	for i = 1, #ancestry, 1 do
        if not util.tableContains(activeNullObjects, ancestry[i]) then   -- This is TEMPORARY
            print("destroying displayObject: "..displayObject.type)
            displayObject.image:removeSelf()
            displayObject.image = nil
            util.removeFromList(activeDisplayObjects, displayObject)
            displayObject = nil
            return 0
        end
		x_offset = x_offset + ancestry[i].x
		y_offset = y_offset + ancestry[i].y
		rotation_offset = rotation_offset + ancestry[i].rotation
	end
	displayObject.image.x = displayObject.x + x_offset -- displayObject.x is unchanging, displayObject.image.x is the displayObjects position on the screen
	displayObject.image.y = displayObject.y + y_offset
	displayObject.image.rotation = displayObject.rotation + rotation_offset
    return 1
end

-- Creates a new Corona recognized display object from its data
local function createDisplayObject(object_data)
	local newObject = {}
	local image
	if object_data.type == "black_square" then
		image = display.newImageRect(obstacleGroup, "Game/Obstacle/black_square.png", CN.COL_WIDTH, CN.COL_WIDTH)
	elseif object_data.type == "spike" then
		image = display.newImageRect(obstacleGroup, "Game/Obstacle/spike.png", CN.COL_WIDTH, CN.COL_WIDTH)
	end
    physics.addBody(image,"static")
	newObject.image = image
	newObject.x = object_data.x
	newObject.y = object_data.y
    newObject.type = object_data.type
	newObject.rotation = object_data.rotation
	newObject.ancestry = object_data.ancestry
	return newObject
end

-- Creates an objects and starts transition from frame_counter to frame_counter+1
local function createObstacle(obstacle_data)
	-- Note that there has to be at least 1 null and 1 display object, otherwise things crash
	-- (And I make fun of you for making a useless obstacle)

    -- Initialize null objects
    for i = 1, #obstacle_data.null_objects, 1 do
            local thisNull = obstacle_data.null_objects[i]
            print("Inserting name = "..thisNull.name)
            table.insert(activeNullObjects, thisNull)

            -- Set the state values of our null object
            thisNull.frame_counter = 0
            local num_frames = #thisNull.position_path
            local this_frame = ( ((thisNull.first_frame - 1) + thisNull.frame_counter) % num_frames ) + 1
            thisNull.x = thisNull.position_path[this_frame].x * CN.COL_WIDTH
            thisNull.y = thisNull.position_path[this_frame].y * CN.COL_WIDTH
            print("name = "..thisNull.name..", initial_x = "..thisNull.x..", initial_y = "..thisNull.y)
            thisNull.rotation = thisNull.rotation_path[this_frame]

            -- Set the null objects on their way! (Start transitions)
            keyframeNull(thisNull)
    end

    -- Initialize display objects
    for i = 1, #obstacle_data.display_objects, 1 do
    	local newObject = createDisplayObject(obstacle_data.display_objects[i])
    	reposition(newObject)
    	table.insert(activeDisplayObjects, newObject)
    end
end



-- Updates all displayObjects (Spikes, squares, powerups, etc...)
local function updateDisplayObjects()
    local i = 1
    while(i <= #activeDisplayObjects) do
        i = i + reposition(activeDisplayObjects[i])
    end
end


-- Update score element
local function update_scoreText()
    scoreText.text = score
end

local function on_victory_tapped(event)
    print("on_victory_tapped")
    bubble.destroyBubbles()

    -- Remove victory thing
    event.target.text:removeSelf()
    event.target:removeSelf()

    -- Remove all obstacles still on screen

    composer.gotoScene("level_select")
end

local function victory()
    timer.pause(slow_gameLoopTimer)

    -- Creates temporary victory button with event listener
    local button = display.newRect(uiGroup, display.contentWidth/2, display.contentHeight/2,
    display.contentWidth/2,display.contentHeight/8)
    button:setFillColor(0,127,127)
    button:addEventListener("tap", on_victory_tapped)

    -- Adds text
    button.text = display.newText(uiGroup, "Back to level select",
        display.contentWidth/2, display.contentHeight/2,
        native.systemFont)
    button.text:setFillColor(0,0,0)

end

local function onEnterFrame()
	updateDisplayObjects()
    bubble.applyForce()
    --bubble.updateNumText()
end

-- Updates obstacles and background (Updates twice a second)
local function gameLoop_slow()
    score = score + 1
    -- Print Active nulls and display objects
    --[[print("Active objects")
    print("    Nulls:")
    for i = 1, #activeNullObjects, 1 do
        print("        "..i..") "..activeNullObjects[i].name)
    end
    print("    DisplayObjects:")
    for i = 1, #activeDisplayObjects, 1 do
        print("        "..i..") "..activeDisplayObjects[i].type)
    end]]--


    -- Check for VICTORY
    if (score == level_data.victory) then
        victory()
    end

    -- Check if we put on another object (The slot in the array is not null)
    if level_data.obstacles[score] then
        print("adding object "..score)
        createObstacle(level_data.obstacles[score])
    end

    update_scoreText()
end

-- Does all the pagentry showing bubbles escaping the pipe etc...
-- Removes all intro-related graphics from screen itself
local function run_intro()
    print("running intro!")
    bubble.introBubbles(bubbleGroup, 10, util.newPoint(display.contentWidth/2,5*display.contentHeight/6))
end

-- Starts the game!
local function start_game()
    print("starting game")
    slow_gameLoopTimer = timer.performWithDelay(1000, gameLoop_slow, 0)
    Runtime:addEventListener("enterFrame",onEnterFrame)

end

-- Method tied to physics collision listener
local function onCollision(event)

end

-- Method tied to runtime touch listener -> Dispatches touched accordingly
local function onTouch(event)
    -- Will probably have to do some math here once you implement powerups to see if you are interacting with the UI
    bubble.onTouch(event)
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Add display groups
    bubbleGroup = display.newGroup()
    obstacleGroup = display.newGroup()
    backgroundGroup = display.newGroup()
    uiGroup = display.newGroup()
    sceneGroup:insert(backgroundGroup)
    sceneGroup:insert(bubbleGroup)
    sceneGroup:insert(obstacleGroup)
    sceneGroup:insert(uiGroup)

    -- Temporary white background (This should be replaced by backgroundGroup later)
    local bg = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
    bg:setFillColor(1,1,1)
    backgroundGroup:insert(bg)

    -- Initialize ui
    score = 0
    scoreText = display.newText(uiGroup, score, display.contentWidth/2, display.contentHeight/8, native.systemFont, 36)
    scoreText:setFillColor(0,0,0)
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        util.printMemUsage()

        -- Initialize level data
        local level = composer.getVariable("level")
        level_data = require ("Levels."..level)

        print("Here we are, playing level ".. level_data.name)
        score = 0
        update_scoreText()

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        -- Start the physics!
        physics.start()
        physics.setGravity(0,0)
        physics.setDrawMode("normal")
        Runtime:addEventListener("collision", onCollision) -- This should probably move somewhere else but it is here for now
        Runtime:addEventListener("touch", onTouch)

        -- Run the intro, then start the game!
        run_intro()
        timer.performWithDelay(0, start_game)
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        Runtime:removeEventListener("enterFrame",onEnterFrame)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view


end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
