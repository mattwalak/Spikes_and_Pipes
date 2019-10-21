-- game.lua
-- © Matthew Walak 2019
-- Where you actually play a level!


local levels = require("levels")
local util = require("util")
local CN = require ("crazy_numbers")
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Temporary white background (This should be replaced by backgroundGroup later)
local bg = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
bg:setFillColor(1,1,1)


-- Initialize physics
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

-- Define display groups
local bubbleGroup
local obstacleGroup
local backgroundGroup
local uiGroup

-- Define game loop
local gameLoopTimer

-- Define important gameplay variables
local score -- Same as height within the level
local obstacle_num

-- Define variable for level data
local level_data

-- ui elements
local scoreText

-- Destroys nestled obstacle data
local function destroyObstacleData(thisObstacleData)
    -- Base case
    if not thisObstacleData then
        return
    end

    -- Recursively destroy
    if type(thisObstacleData.object) == "table" then
        destroyObstacleData(thisObstacleData.object)
    end

    thisObstacleData = nil
end

-- Transitions an obstacle from keyframe to keyframe + 1
local function keyframeObstacle(obstacleGroup)
    if not obstacleGroup then
        print("nothing in keyframeObstacle")
        return
    end

    local obstacle_data = obstacleGroup.obstacle_data
    local name = obstacleGroup.obstacle_data.name
    local num_keyframes = (#obstacle_data.path/2)
    print("Entering keyframeObstacle with: "..name)

    -- Update keyframe for wrap-around
    local keyframe = ((obstacle_data.frame_counter - 1) % num_keyframes) + 1

    -- Initialize next_keyframe (With wrap-arround value)
    local next_keyframe = keyframe + 1
    next_keyframe = ((next_keyframe - 1) % num_keyframes) + 1

    -- Initialize with number of times this animation has looped completely
    local revolutions = (obstacle_data.frame_counter - 1)/num_keyframes
    revolutions = math.floor(revolutions)

    print("frame_counter = "..obstacleGroup.obstacle_data.frame_counter.."; keyframe = "..keyframe.."; next_keyframe = "..next_keyframe.."; revolutions = "..revolutions.."; num_keyframes = ".. num_keyframes)

    -- Full loop compelte actions
    if(revolutions > 0) then
        if(obstacle_data.on_complete == "destroy") then
            print("DESTROYING name: "..name)
            destroyObstacleData(obstacleGroup.obstacle_data)
            obstacleGroup.obstacle_data = nil
            obstacleGroup:removeSelf();
            return
        elseif(obstacle_data.on_complete == "stop") then
            print("STOPPING animation for name: "..name)
            return
        elseif(obstacle_data.on_complete == "loop") then
            -- Do nothing
        end
    end

    local transition_time = obstacle_data.time[keyframe]
    local next_x = obstacle_data.path[(next_keyframe*2)-1] * CN.COL_WIDTH
    local next_y = obstacle_data.path[next_keyframe*2] * CN.COL_WIDTH

    print("transitioning; name = "..obstacle_data.name.."; x = "..next_x.."; y = "..next_y.."; time = "..transition_time)

    -- Update our frame count
    obstacleGroup.obstacle_data.frame_counter = obstacleGroup.obstacle_data.frame_counter + 1
        
    transition.to(obstacleGroup, {
        time = transition_time,
        x = next_x,
        y = next_y,
        onComplete = keyframeObstacle
    })
end

-- Creates an objects and starts transition from frame_counter to frame_counter+1
local function createObstacle(obstacle_data)
    local name = obstacle_data.name
    print("Entering createObstacle with: "..name)

    -- Will probably need to set anchor point at some point
    local thisObstacleGroup = display.newGroup()
    thisObstacleGroup.obstacle_data = obstacle_data

    -- Set initial x and y (Accounting for overflow)
    local num_keyframes = #obstacle_data.path/2
    local frame_counter = ((obstacle_data.frame_counter - 1) % num_keyframes) + 1

    thisObstacleGroup.x = obstacle_data.path[(frame_counter*2)-1]*CN.COL_WIDTH
    thisObstacleGroup.y = obstacle_data.path[frame_counter*2]*CN.COL_WIDTH
    print("Setting initial values for name: "..name.."; x: "..thisObstacleGroup.x..", y: "..thisObstacleGroup.y)

    -- Add the obstacles object
    local object = obstacle_data.object
    if not object then
        -- No object... don't do anything... I think
        print("no object for: "..name)
    elseif type(object) == "table" then
        -- Recursively nestled objects!
        thisObstacleGroup:insert(createObstacle(obstacle_data.object))
    elseif type(object) == "string" then
        if object == "black_square" then
            display.newImageRect(thisObstacleGroup, "Game/Obstacle/black_square.png", CN.COL_WIDTH, CN.COL_WIDTH)
        end
    end

    keyframeObstacle(thisObstacleGroup)
    print("ending createObstacle with name:"..thisObstacleGroup.obstacle_data.name)
    return thisObstacleGroup
end


-- Update score element
local function update_scoreText()
    scoreText.text = score
end

local function victory()
    print("VICTORY!!!")
    timer.pause(gameLoopTimer)
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
        obstacleGroup:insert(createObstacle(level_data.obstacles[score]))
    end

    update_scoreText()
    --updateObstacles()
    --updateBackground()
end

-- Does all the pagentry showing bubbles escaping the pipe etc...
-- Removes all intro-related graphics from screen itself
local function run_intro()
    print("running intro!")
end

-- Starts the game!
local function start_game()
    print("starting game")
    gameLoopTimer = timer.performWithDelay(500, gameLoop_slow, 0)
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

    -- Initialize level data
    local level = composer.getVariable("level")
    level_data = require ("Levels."..level)
    obstacle_num = 1


    print("Here we are, playing level ".. level_data.name)
    score = 0

    -- Initialize ui
    scoreText = display.newText(uiGroup, score, display.contentWidth/2, display.contentHeight/8, native.systemFont, 36)
    scoreText:setFillColor(0,0,0)

    run_intro()
    timer.performWithDelay(0, start_game)

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

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
