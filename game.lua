-- game.lua
-- © Matthew Walak 2019
-- Where you actually play a level!


local levels = require("levels")
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

-- Define variable for level data
local level_data

-- ui elements
local scoreText


-- Update score element
local function update_scoreText()
    scoreText.text = score
end

-- Updates obstacles and background (Updates twice a second)
local function gameLoop_slow()
    print("loop!")
    score = score + 1
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
