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

-- Transitions an obstacle from keyframe to keyframe + 1
local function keyframeObstacle(obstacleGroup, obstacle_data, keyframe)
    if #obstacle_data.path < ((keyframe+1)*2) then
        -- We have reached the end of the animation!
        print("Animation end")
    else
        transition.to(obstacleGroup, {
          time = obstacle_data.animation_options.time[keyframe],
          x = obstacle_data.path[(keyframe*2)+1],
          y = obstacle_data.path[(keyframe*2)+2]
      })

    end
end

-- Creates an objects and starts in from keyframe 1 to 2
local function createObstacle(parentGroup, obstacle_data)
    -- Will probably need to set anchor point at some point
    thisObstacleGroup = display.newGroup()

    local object = obstacle_data.object
    -- Add the obstacles object
    if not object then
        -- No object... don't do anything... I think
        return
    elseif type(object) == "table" then
        -- Recursively nestled objects!
        createObstacle(thisObstacleGroup, obstacle_data.object)
    elseif type(object) == "string" then
        if object == "black_square" then
            print("Adding black square I think")
            local sprite = display.newImageRect(thisObstacleGroup, "Game/Obstacle/black_square.png", CN.COL_WIDTH, CN.COL_WIDTH)
        end
    end

    -- Set initial x and y
    thisObstacleGroup.x = obstacle_data.path[1]*CN.COL_WIDTH
    thisObstacleGroup.y = obstacle_data.path[2]*CN.COL_WIDTH

    keyframeObstacle(thisObstacleGroup, obstacle_data, 1)

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
        createObstacle(obstacleGroup, level_data.obstacles[score])
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
