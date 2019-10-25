-- game.lua
-- © Matthew Walak 2019
-- Where you actually play a level!


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
local gameLoopTimer

-- Define important gameplay variables
local score -- Same as height within the level
local activeDisplayObjects = {} -- All visible blocks, spikes, and powerups
local activeNullObjects = {} -- All active Null objects

-- Define variable for level data
local level_data

-- ui elements
local scoreText

-- Removes everything from

-- Stops all null object transitions and sets them to nil
local function stopNulls()
    for i = 1, #activeNullObjects, 1 do
        transition.cancel(activeNullObjects[i])
        activeNullObjects[i] = nil -- Should probably remove them from the table... maybe?
    end
end

-- Transitions a null object from current_frame to current_frame + 1
local function keyframeNull(thisNull)
    local num_frames = #thisNull.position_path

    -- Calculate current frame accounting for overflow
    local current_frame = ( ((thisNull.first_frame - 1) + frame_counter) % num_frames ) + 1

    -- Number of times we have completed the full animation
    -- (If > 1, we are currently at first frame ie. cycle is already complete)
    local revolutions = thisNull.frame_counter/num_frames
    if(revolutions > 0) then
        if(thisNull.on_complete == "destroy") then
            transition.cancel(thisNull) -- In case the rotation keyframe hasn't finished
            thisNull = nil  -- DisplayObjects know if one of their parents is
            return          -- nil they should delete themselves
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
    local next_x = thisNull.position_path[next_frame].x
    local next_y = thisNull.position_path[next_frame].y
    local next_rotation = thisNull.rotation_path[next_frame]

    -- To ensure transitions start at the same time, only the position transition
    -- causes the next transition to be called
    transition.to(obstacleGroup, {
        time = transition_time,
        x = next_x,
        y = next_y,
        transition = thisNull.position_interpolation,
        onComplete = keyframeObstacle
    })

    transition.to(obstacleGroup, {
        time = transition_time,
        rotation = next_rotation,
        transition = thisNull.rotation_interpolation,
    })


    --[[
    -- OLD IMPLEMENTATION
    local obstacle_data = obstacleGroup.obstacle_data
    local name = obstacleGroup.obstacle_data.name
    local num_keyframes = (#obstacle_data.path/2)

    -- Update keyframe for wrap-around
    local keyframe = ((obstacle_data.frame_counter - 1) % num_keyframes) + 1

    -- Initialize next_keyframe (With wrap-arround value)
    local next_keyframe = keyframe + 1
    next_keyframe = ((next_keyframe - 1) % num_keyframes) + 1

    -- Initialize with number of times this animation has looped completely
    local revolutions = (obstacle_data.frame_counter - 1)/num_keyframes
    revolutions = math.floor(revolutions)

    -- Full loop compelte actions
    if(revolutions > 0) then
        if(obstacle_data.on_complete == "destroy") then
            stopTransitions(obstacleGroup)
            obstacleGroup:removeSelf()
            obstacleGroup = nil
            return
        elseif(obstacle_data.on_complete == "stop") then
            return
        elseif(obstacle_data.on_complete == "loop") then
            -- Do nothing
        end
    end

    -- Update our frame count and perform transition
    obstacleGroup.obstacle_data.frame_counter = obstacleGroup.obstacle_data.frame_counter + 1

    local transition_time = obstacle_data.time[keyframe]
    local next_x = obstacle_data.path[(next_keyframe*2)-1] * CN.COL_WIDTH
    local next_y = obstacle_data.path[next_keyframe*2] * CN.COL_WIDTH

    transition.to(obstacleGroup, {
        time = transition_time,
        x = next_x,
        y = next_y,
        onComplete = keyframeObstacle
    })]]
end

-- Creates an objects and starts transition from frame_counter to frame_counter+1
local function createObstacle(obstacle_data)
    -- Initialize null objects
    for i = 1, #obstacle_data.null_objects, 1 do -- We know there is at least 1 null (parent)
            local thisNull = obstacle_data.null_objects[i]
            table.insert(activeNullObjects, thisNull)

            -- Set the state values of our null object
            thisNull.frame_counter = 0
            local num_frames = #thisNull.position_path
            local this_frame = ( ((thisNull.first_frame - 1) + frame_counter) % num_frames ) + 1
            thisNull.x = thisNull.position_path[this_frame].x
            thisNull.y = thisNull.position_path[this_frame].y
            thisNull.rotation = thisNull.rotation_path[this_frame]

            -- Set the null objects on their way! (Start transitions)
            keyframeNull(thisNull)
    end





    --[[
    -- OLD IMPLEMENTATION
    local name = obstacle_data.name

    -- Set up new group for obstacle
    -- Will probably need to set anchor point at some point
    local thisObstacleGroup = display.newGroup()
    thisObstacleGroup.obstacle_data = obstacle_data

    -- find frame and update position
    local num_keyframes = #obstacle_data.path/2
    local this_keyframe = ((obstacle_data.frame_counter - 1) % num_keyframes) + 1
    thisObstacleGroup.x = obstacle_data.path[(this_keyframe*2)-1]*CN.COL_WIDTH
    thisObstacleGroup.y = obstacle_data.path[this_keyframe*2]*CN.COL_WIDTH
    thisObstacleGroup.rotation = obstacle_data.animation_options.rotation[(this_keyframe*2)-1]

    -- Recursively add objects to this obstacle
    local num_objects
    if obstacle_data.objects then
        num_objects = #obstacle_data.objects
    else
        num_objects = 0
    end

    for i = 1, num_objects, 1 do
        local thisObject = obstacle_data.objects[i]
        if not thisObject then
            -- Do nothing
        elseif type(thisObject) == "table" then
            -- Recursively nestled objects!
            thisObstacleGroup:insert(createObstacle(obstacle_data.objects[i]))
        elseif type(thisObject) == "string" then
            if thisObject == "black_square" then
                local black_square = display.newImageRect(thisObstacleGroup, "Game/Obstacle/black_square.png", CN.COL_WIDTH, CN.COL_WIDTH)
                physics.addBody(black_square, "static")
            elseif thisObject == "spike" then
                local spike = display.newImageRect(thisObstacleGroup, "Game/Obstacle/spike.png", CN.COL_WIDTH, CN.COL_WIDTH)
                physics.addBody(spike, "static")
            end
        end
    end

    -- Begin obstacle animation
    keyframeObstacle(thisObstacleGroup)
    return thisObstacleGroup]]--
end


-- Update score element
local function update_scoreText()
    scoreText.text = score
end

local function on_victory_tapped(event)
    print("on_victory_tapped")

    -- Remove victory thing
    event.target.text:removeSelf()
    event.target:removeSelf()

    -- Remove all obstacles still on screen

    composer.gotoScene("level_select")
end

local function victory()
    timer.pause(gameLoopTimer)

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

-- Updates obstacles and background (Updates twice a second)
local function gameLoop_slow()
    score = score + 1

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
    --bubble.introBubbles(bubbleGroup,display.contentWidth/2,5*display.contentHeight/6,10)
end

-- Starts the game!
local function start_game()
    print("starting game")
    gameLoopTimer = timer.performWithDelay(1000, gameLoop_slow, 0)

end

-- Method tied to physics collision listener
local function onCollision(event)
    print("Things are colliding :)")
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
        local level_data_original = require ("Levels."..level)
        level_data = util.deepcopy(level_data_original)

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
