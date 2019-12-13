local CN = require("crazy_numbers")
local composer = require( "composer" )
local util = require("util")

-- level_select.lua
-- © Matthew Walak 2019
-- Inferface for choosing the level to play

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function on_wind_tap(event)
    CN.DBG_TOUCH_TYPE = event.target.wind_type
    print("Setting DBG_TOUCH_TYPE to "..CN.DBG_TOUCH_TYPE)
end

-- Handles button taps
local function on_button_tap(event)
    print("Going to level "..event.target.level)
    composer.setVariable("level",event.target.level)
    composer.gotoScene("game")
end



-- Sets up temporary level buttons for navigation durring preliminary stages
local function setupTempButtons(sceneGroup)
    -- Creates temporary level buttons (With action listener to same method)
    local button1 = display.newRect(sceneGroup, display.contentWidth/2, display.contentHeight/4,
    display.contentWidth/2,display.contentHeight/10)
    button1:setFillColor(127,0,127)
    button1.level = "Tests.1"
    button1:addEventListener("tap", on_button_tap)

    local button2 = display.newRect(sceneGroup, display.contentWidth/2, 2*display.contentHeight/4,
    display.contentWidth/2,display.contentHeight/10)
    button2:setFillColor(127,0,127)
    button2.level = "Tests.2"
    button2:addEventListener("tap", on_button_tap)

    local button3 = display.newRect(sceneGroup, display.contentWidth/2, 3*display.contentHeight/4,
    display.contentWidth/2,display.contentHeight/10)
    button3:setFillColor(127,0,127)
    button3.level = "Tests.3"
    button3:addEventListener("tap", on_button_tap)

    -- Adds text for level selection
    local text1 = display.newText(sceneGroup, "Test Level 1",
        display.contentWidth/2, display.contentHeight/4,
        native.systemFont)
    text1:setFillColor(0,0,0)

    local text2 = display.newText(sceneGroup, "Test Level 2",
        display.contentWidth/2, 2*display.contentHeight/4,
        native.systemFont)
    text2:setFillColor(0,0,0)

    local text3 = display.newText(sceneGroup, "Test Level 3",
        display.contentWidth/2, 3*display.contentHeight/4,
        native.systemFont)
    text3:setFillColor(0,0,0)

    -- Set wind gen method
    local button1 = display.newRect(sceneGroup, display.contentWidth/4, 7*display.contentHeight/8,
    display.contentWidth/6,display.contentHeight/10)
    button1:setFillColor(127,127,0)
    button1.wind_type = "1"
    button1:addEventListener("tap", on_wind_tap)

    local button2 = display.newRect(sceneGroup, 2*display.contentWidth/4, 7*display.contentHeight/8,
    display.contentWidth/6,display.contentHeight/10)
    button2:setFillColor(127,127,0)
    button2.wind_type = "2"
    button2:addEventListener("tap", on_wind_tap)

    local button3 = display.newRect(sceneGroup, 3*display.contentWidth/4, 7*display.contentHeight/8,
    display.contentWidth/6,display.contentHeight/10)
    button3:setFillColor(127,127,0)
    button3.wind_type = "3"
    button3:addEventListener("tap", on_wind_tap)

    -- Adds text for level selection
    local text1 = display.newText(sceneGroup, "Wind 1",
        display.contentWidth/4, 7*display.contentHeight/8,
        native.systemFont)
    text1:setFillColor(0,0,0)

    local text2 = display.newText(sceneGroup, "Wind 2",
        2*display.contentWidth/4, 7*display.contentHeight/8,
        native.systemFont)
    text2:setFillColor(0,0,0)

    local text3 = display.newText(sceneGroup, "Wind 3",
        3*display.contentWidth/4, 7*display.contentHeight/8,
        native.systemFont)
    text3:setFillColor(0,0,0)



end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    
    setupTempButtons(sceneGroup)


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
