-- title_screen.lua
-- © Matthew Walak 2019
-- Just a nice thing to look at before going into level select screen

local CN = require("crazy_numbers")
local composer = require( "composer" )
local util = require("util")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function on_play_tapped(event)
	print("you clicked me!")
	composer.gotoScene("level_select")
end





 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Creates temporary play button with event listener
 	local button = display.newRect(sceneGroup, display.contentWidth/2, display.contentHeight/2,
 	display.contentWidth/2,display.contentHeight/8)
 	button:setFillColor(0,127,0)
 	button:addEventListener("tap", on_play_tapped)

 	-- Adds text (so we know where we are)
 	local text = display.newText(sceneGroup, "title_screen", 
 		display.contentWidth/2, display.contentHeight/2,
 		native.systemFont)
 	text:setFillColor(0,0,0)


 	local crazyGroup = display.newGroup()
 	sceneGroup:insert(crazyGroup)

    local crazierGroup = display.newGroup()
    crazyGroup:insert(crazierGroup)

 	local crazy = display.newRect(crazierGroup, 0,0,100,100)
 	crazy:setFillColor(127,0,0)

 	crazy2 = display.newRect(crazierGroup, 0,0,100,100)
 	crazy2:setFillColor(0,0,127)

 	transition.to(crazyGroup, 
 		{time=2000, x=0, y=display.contentHeight, rotation=180, transition=easing.inQuart})
 	transition.to(crazierGroup,
 		{time = 3000, x=-display.contentWidth, y=0})

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