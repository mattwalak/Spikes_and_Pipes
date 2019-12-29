-- game.lua
-- © Matthew Walak 2019
-- Where you actually play a level!!!


local levels = require("levels")
local util = require("util")
local CN = require ("crazy_numbers")
local A = require ("animation")
local lb = require ("level_builder")
local composer = require( "composer" )
local bubble = require("bubble")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize physics
local physics = require("physics")

-- Game borders
local leftBorder
local rightBorder
local bottomBorder
local topBorder

-- Define display groups
local bubbleGroup
local obstacleGroup
local backgroundGroup
local uiGroup
local padGroup -- In front of everything

-- Define important gameplay variables
local score -- Total normalized seconds offset by height of heighest bubble
local total_norm_sec -- Total normalized seconds
local activeDisplayObjects = {} -- All visible blocks, spikes, and powerups
local activeNullObjects = {} -- All active Null objects

local activeObstacles = {} -- List of pointers to parent null for all active obstacles (1 for each obstacle)
local activeTransitioners = {} -- One transition for each null object


local last_frame_time -- Time in ms of the last frame render
local time_scale -- Value of each ms in game time

local gameStarted = false

-- Define variable for level data
local level_data

-- ui elements
local scoreText

-- Screen size data & pads
local _top = display.screenOriginY
local _left = display.screenOriginX
local _bottom = display.actualContentHeight
local _right = display.actualContentWidth
local _width = display.contentWidth
local _height = display.contentHeight
local leftPad
local bottomPad
local rightPad
local topPad

-- Draws a checkerboard for debug things
local function drawCheckerboard()
    local yMax = math.ceil(display.contentHeight/CN.COL_WIDTH)
    print("x: 10, y: "..yMax)
    for y = 0, yMax, 1 do
        for x = 0, CN.COL_NUM, 1 do
            local rect = display.newRect(backgroundGroup, (x*CN.COL_WIDTH) + CN.COL_WIDTH/2, (y*CN.COL_WIDTH) + CN.COL_WIDTH/2,
                CN.COL_WIDTH, CN.COL_WIDTH)
            if(((x+y)%2) == 0) then
                rect:setFillColor(.5, .5, .5)
            else
                rect:setFillColor(1,1,1)
            end
        end
    end
end


-- Clears everything from the screen
-- Does so by traversing every null, ultimately reaching every display object
local function clearScreen()
    while activeNullObjects[1] do
        local thisNull = activeNullObjects[1]
        if thisNull.children and (type(thisNull.children) == "table") then
            -- Stop transitions for any displayObjects underneath
            for i = 1, #thisNull.children, 1 do
                if thisNull.children[i].type ~= "null" then
                    thisObject = thisNull.children[i]
                    if thisObject.image.collected then
                    	
                    else
                        thisObject.image:removeSelf()
                        util.removeFromList(activeDisplayObjects, thisObject.image)
                        thisObject.image = nil
                    end
                    thisObject = nil
                end
            end
        end
        util.removeFromList(activeNullObjects, thisNull)
        thisNull = nil
    end
end

-- Stops all object transitions and sets them to nil
local function stopTransitions()
    for i = 1, #activeNullObjects, 1 do
        thisNull = activeNullObjects[i]
        transition.cancel(thisNull)
        if thisNull.children and (type(thisNull.children) == "table") then
            -- Stop transitions for any displayObjects underneath
            for i = 1, #thisNull.children, 1 do
                if thisNull.children[i].type ~= "null" then
                    transition.cancel(thisNull.children[i])
                end
            end
        end
    end
end

-- Updates all transition objects and corresponding null objects
local function updateTransitions(dt)
	local scaled_time = dt*time_scale
	for i = 1, #activeTransitioners, 1 do
		local t = activeTransitioners[i]
		t.internal_time = t.internal_time + scaled_time
		--print("["..i.."] "..t.name)
		--print("\tInternal time = "..t.internal_time)
		
		if t.internal_time/t.total_time >= 1 then
			if t.on_complete == "destroy" then
				-- DESTROY
			elseif t.on_complete == "stop" then
				-- STOP!
			end
		end

		local time = t.internal_time%t.total_time
		--print("\ttime = "..time)

		-- Find the most recent frame percent
		local last_frame = -1
		local time_sum = 0
		--print("\ttransition_time:")
		--[[
		for i = 1, #t.transition_time, 1 do
			time_sum = time_sum + t.transition_time[i]
			--print("\t\t["..i.."] = "..t.transition_time[i].."; time_sum = "..time_sum)
		end]]--
		time_sum = 0
		for i = 1, #t.transition_time, 1 do
			time_sum = time_sum + t.transition_time[i]
			if time < time_sum then
				last_frame = i
				break
			end
		end
		local next_frame = (last_frame%(#t.transition_time))+1
		--print("\tlast_frame = "..last_frame.."; next_frame = "..next_frame)

		local time_into_frame = time - (time_sum - t.transition_time[last_frame])-- Time into transition
		--print("\ttime_into_frame = "..time_into_frame)
		local total_frame_time = t.transition_time[last_frame]
		--print("\ttotal_frame_time = "..total_frame_time)
		local percent = time_into_frame/total_frame_time
		percent = util.scale(percent, "linear")
		--print("\tpercent = "..percent)

		-- Calculate new position
		local ori_pos = t.position_path[last_frame]
		local ori_rot = t.rotation_path[last_frame]
		local new_pos = t.position_path[next_frame]
		local new_rot = t.rotation_path[next_frame]
		local new_x = ori_pos.x+((new_pos.x-ori_pos.x)*percent)
		local new_y = ori_pos.y+((new_pos.y-ori_pos.y)*percent)
		local new_rot = ori_rot+((new_rot-ori_rot)*percent)
		--print("\tnew_x = "..new_x..", new_y = "..new_y..", new_rot = "..new_rot)

		t.linkedNull.x = new_x
		t.linkedNull.y = new_y
		t.linkedNull.rotation = new_rot
	end
end

-- Stops all transitions and destroys a null object and its children (And grandchildren)
local function destroyObject(thisObject)
    -- Test if destroyed before
	if not thisObject then return end

    if thisObject.type == "null" then
        transition.cancel(thisObject) -- Just changed this from deleting by tag/name... Check to see if you can/should eliminate tagging transitions
        if thisObject.children then
        	for i = 0, #thisObject.children, 1 do
        		destroyObject(thisObject.children[i])
        	end
        end
        util.removeFromList(activeNullObjects, thisObject)
        thisObject = nil  -- DisplayObjects know if one of their parents is nill (They will delete themselves)
    else
        -- Test if object already removed (ie coin collected)
        if thisObject.image.collected then 
            thisObject.image = nil
            thisObject = nil
        else
            util.removeFromList(activeDisplayObjects, thisObject.image)
            thisObject.image:removeSelf()
            thisObject.image = nil
            thisObject = nil
        end
    end
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
        	destroyObject(thisNull)
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

    -- If transition time is negative, we stop everything
    if transition_time < 0 then 
        --print("Canceling transition")
        return 
    end

    -- To ensure transitions start at the same time, only the position transition
    -- causes the next transition to be called

    transition.to(thisNull, {
        time = transition_time,
        rotation = next_rotation,
        tag = thisNull.name,
        transition = thisNull.rotation_interpolation
    })

    transition.to(thisNull, {
        time = transition_time,
        x = next_x,
        y = next_y,
        transition = thisNull.position_interpolation,
        tag = thisNull.name,
        onComplete = keyframeNull
    })

    
end

-- Repositions a display object based on its ancestry
-- Depth indicates how deep we are
-- Returns -1 if we remove an element, 0 otherwise <-- THIS IS BAD AND TEMPORARY
local function reposition(displayObject)
    local total_x = 0
    local total_y = 0
    local last_rot = 0
    local total_rot = 0

    local ancestry = displayObject.ancestry
    for i = 1, #ancestry+1, 1 do
        local thisObject
        if i > #ancestry then
            thisObject = displayObject
        else
            thisObject = ancestry[i]
            thisObject.r_x = thisObject.x
            thisObject.r_y = thisObject.y
            thisObject.r_rot = thisObject.rotation
        end

        local r_x = thisObject.r_x*math.cos(math.rad(total_rot))-thisObject.r_y*math.sin(math.rad(total_rot))
        local r_y = thisObject.r_y*math.cos(math.rad(total_rot))+thisObject.r_x*math.sin(math.rad(total_rot))
        total_x = total_x + r_x
        total_y = total_y + r_y
        total_rot = total_rot + thisObject.r_rot
        last_rot = thisObject.r_rot
    end

    -- Place this object (rotated) at this point
    displayObject.x = total_x
    displayObject.y = total_y
    displayObject.rotation = total_rot
end

-- OBSTACLE OPTION 1: Creates a new Corona recognized display object from its data
local function createDisplayObject(thisObject, ancestry)
	local image
    local imageOutline
	if thisObject.type == "black_square" then
		image = display.newImageRect(obstacleGroup, "Game/Obstacle/black_square.png", CN.COL_WIDTH, CN.COL_WIDTH)
        imageOutline = graphics.newOutline(2, "Game/Obstacle/black_square.png")
    elseif thisObject.type == "spike" then
		image = display.newImageRect(obstacleGroup, "Game/Obstacle/spike.png", CN.COL_WIDTH, CN.COL_WIDTH)
        imageOutline = graphics.newOutline(2, "Game/Obstacle/spike.png")
    elseif thisObject.type == "coin" then
        print("adding coin")
        image = display.newSprite(A.sheet_coin, A.sequences_coin)
        obstacleGroup:insert(image)
        image:play()
        image.collected = false
        imageOutline = graphics.newOutline(2, "Game/Item/coin_2d.png")
    elseif thisObject.type == "text" then
    	print("New text")
    	image = display.newText(obstacleGroup, thisObject.text, thisObject.x, thisObject.y, thisObject.font, thisObject.fontSize)
    	image:setFillColor( thisObject.color[1], thisObject.color[2], thisObject.color[3] )
    	imageOutline = nil
    end
    image.type = thisObject.type
    image.r_x = thisObject.x * CN.COL_WIDTH
    image.r_y = thisObject.y * CN.COL_WIDTH
    image.r_rot = thisObject.rotation
    image.ancestry = ancestry
    image.object = thisObject -- Used to set both to nil when destroying
    thisObject.image = image

    if thisObject.type ~= "text" then
    	physics.addBody(image, "static", {outline=imageOutline})
    end

	return image
end

-- Returns a new transitioner object linked to the active obstacle
local function newTransitioner(obstacleData, linkedNull)
	-- We know obstacleData represents a null object
	local t = {} -- This transitioner
	t.name = obstacleData.name.."_transitioner"
	t.linkedNull = linkedNull

	-- Set internal time
    local internal_time = 0
    if obstacleData.time_offset then
    	internal_time = internal_time + time_offset
    end
    if obstacleData.first_frame ~= 1 then
    	internal_time = internal_time + obstacleData.transition_time[obstacleData.first_frame-1]
    end
    t.internal_time = internal_time

    -- Calculate and set total time
    local total_time = 0
    for i = 1, #obstacleData.transition_time, 1 do
    	total_time = total_time + obstacleData.transition_time[i]
    end
    t.total_time = total_time

    -- Set animation data
    t.position_path = obstacleData.position_path
    t.rotation_path = obstacleData.rotation_path
    t.transition_time = obstacleData.transition_time
    t.position_interpolation = obstacleData.position_interpolation
    t.rotation_interpolation = obstacleData.rotation_interpolation
    t.on_complete = obstacleData.on_complete

    return t
end	

-- Returns a nestled obstacle. Creates all neccesary transitions for nulls in between
local function newObstacle(obstacleData)
    if not obstacleData then return {} end
    local thisObject = {}

    if obstacleData.type == "null" then
    	thisObject.type = "null"
    	thisObject.name = obstacleData.name
    	thisObject.x = 0 -- Will be updated later
    	thisObject.y = 0
    	thisObject.rotation = 0

    	-- Create transitioner
    	local transitioner = newTransitioner(obstacleData, thisObject)
    	table.insert(activeTransitioners, transitioner)

    	-- Get children
    	thisObject.children = {}
    	if obstacleData.children then
    		for i = 1, #obstacleData.children, 1 do
    			local newChild = newObstacle(obstacleData.children[i])
    			table.insert(thisObject.children, newChild)
    		end
    	end
    else
    	thisObject.type = obstacleData.type -- Some display object
    	thisObject.x = obstacleData.x
    	thisObject.y = obstacleData.y
    	thisObject.rotation = obstacleData.rotation
    	thisObject.image = nil -- To avoid having the object flash momentarally at (0,0) we will ad the image once its position is calculated
    end

    return thisObject



    --[[
    -- print("type = "..thisObstacle.type)
    if thisObstacle.type == "null" then
    	createNullObject(thisObstacle)

    	
        local thisNull = thisObstacle
        -- print("Inserting name = "..thisNull.name)
        table.insert(activeNullObjects, thisNull)

        -- Set the state values of our null object
        thisNull.frame_counter = 0
        local num_frames = #thisNull.position_path
        local this_frame = ( ((thisNull.first_frame - 1) + thisNull.frame_counter) % num_frames ) + 1
        thisNull.x = thisNull.position_path[this_frame].x * CN.COL_WIDTH
        thisNull.y = thisNull.position_path[this_frame].y * CN.COL_WIDTH
        -- print("name = "..thisNull.name..", initial_x = "..thisNull.x..", initial_y = "..thisNull.y)
        thisNull.rotation = thisNull.rotation_path[this_frame]

        -- Set the null objects on their way! (Start transitions)
        keyframeNull(thisNull)

        if not thisObstacle.children then return end
        for i = 1, #thisObstacle.children, 1 do
            local newAncestry = {}
            newAncestry = util.shallowcopy(ancestry)
            table.insert(newAncestry, thisObstacle)
            createObstacle(thisObstacle.children[i], newAncestry)
        end
    else
        local newDisplayObject = createDisplayObject(thisObstacle, ancestry)
        table.insert(activeDisplayObjects, newDisplayObject)
        reposition(newDisplayObject)
    end
    ]]--
end

-- Updates all displayObjects (Spikes, squares, powerups, etc...)
local function updateDisplayObjects()
    for i = 1, #activeDisplayObjects, 1 do
        reposition(activeDisplayObjects[i])
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
    clearScreen()

    composer.gotoScene("level_select")
end

local function gameOver()
    stopTransitions()

    -- Creates temporary victory button with event listener
    local button = display.newRect(uiGroup, _width/2, _height/2,
    _width/2,_height/8)
    button:setFillColor(127,0,0)
    button:addEventListener("tap", on_victory_tapped)

    -- Adds text
    button.text = display.newText(uiGroup, "Back to level select",
        _width/2, _height/2,
        native.systemFont)
    button.text:setFillColor(0,0,0)

end

local function onEnterFrame()
	if gameStarted then
		local t = system.getTimer()
		local dt = t - last_frame_time
		last_frame_time = t

		total_norm_sec = total_norm_sec + (time_scale*dt)
		--updateTransitions(dt) -- TODO
		updateDisplayObjects()
	    bubble.applyForce()
	    if gameStarted and (bubble.numBubbles() == 0) then
	        gameStarted = false
	        gameOver()
	    end

	    score = total_norm_sec
	    update_scoreText()
    end
end

-- Does all the pagentry showing bubbles escaping the pipe etc...
-- Removes all intro-related graphics from screen itself
local function run_intro()
    print("running intro!")
    bubble.introBubbles(bubbleGroup, 10, util.newPoint(_width/2,5*_height/6))
end

-- Starts the game!
local function start_game()
    print("starting game")
    Runtime:addEventListener("enterFrame",onEnterFrame)
    gameStarted = true
end

-- Method tied to physics collision listener
local function onCollision(event)
    if(event.phase == "began") then

		local obj1 = event.object1
		local obj2 = event.object2

		--SPIKE COLLISION
		if(obj1.type == "bubble" and obj2.type == "spike") then
			if(event.element2 == 2) then
				return
			end
            bubble.popBubble(obj1)

		elseif(obj1.type == "spike" and obj2.type == "bubble") then
			if(event.element1 == 2) then
				return
			end
			bubble.popBubble(obj2)

        -- COIN COLLISION
		elseif(obj1.type == "bubble" and obj2.type == "coin") then
            if(event.element2 == 2) then
                return
            end
            print("coin collision!")
            util.removeFromList(activeDisplayObjects, obj2)
            obj2:removeSelf()
            obj2.collected = true
        elseif(obj1.type == "coin" and obj2.type == "bubble") then
            if(event.element1 == 2) then
                return
            end
            print("coin collision!")
            util.removeFromList(activeDisplayObjects, obj1)
            obj1:removeSelf()
            obj1.collected = true
        end
	end
end

-- Method tied to runtime touch listener -> Dispatches touched accordingly
local function onTouch(event)
    -- Will probably have to do some math here once you implement powerups to see if you are interacting with the UI
    bubble.onTouch(event)
end


local function addObstacle_tapped(event)
	print("addObstacle_tapped")
	local obstacle = newObstacle(lb.obstacle(10000, 1))
	table.insert(activeObstacles, obstacle)
end

local function addTime_tapped(event)
	print("addTime_tapped")
	updateTransitions(1000)
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    activeDisplayObjects = {}
    activeNullObjects = {}

    -- Add display groups
    bubbleGroup = display.newGroup()
    obstacleGroup = display.newGroup()
    backgroundGroup = display.newGroup()
    uiGroup = display.newGroup()
    padGroup = display.newGroup()
    sceneGroup:insert(backgroundGroup)
    sceneGroup:insert(bubbleGroup)
    sceneGroup:insert(obstacleGroup)
    sceneGroup:insert(uiGroup)
    sceneGroup:insert(padGroup)

    -- Initialize borders
    leftBorder = display.newRect(-100, _height/2, 200, _height)
    rightBorder = display.newRect(_width+100, _height/2, 200, _height)
    topBorder = display.newRect(_width/2, -100, _width, 200)
    bottomBorder = display.newRect(_width/2, _height+100, _width, 200)
    leftBorder.type = "border"
    rightBorder.type = "border"
    topBorder.type = "border"
    bottomBorder.type = "border"
    obstacleGroup:insert(leftBorder)
    obstacleGroup:insert(rightBorder)
    obstacleGroup:insert(topBorder)
    obstacleGroup:insert(bottomBorder)

    -- Cover unused portions (Temporary solution)
    local sideWidth = (_right-_width)/2
    local topHeight = (_bottom-_height)/2

    leftPad = display.newRect(_left+(sideWidth/2), _top+(_bottom/2), sideWidth, _bottom)
    rightPad = display.newRect(_width+(sideWidth/2), _top+(_bottom/2), sideWidth, _bottom)
    topPad = display.newRect(_width/2, _top+(topHeight/2), _right, topHeight)
    bottomPad = display.newRect(_width/2, _height+(topHeight/2), _right, topHeight)

    leftPad:setFillColor(0,0,0)
    rightPad:setFillColor(0,0,0)
    topPad:setFillColor(0,0,0)
    bottomPad:setFillColor(0,0,0)
    
    -- Temporary white background (This should be replaced by backgroundGroup later)
    local bg = display.newRect(_width/2, _height/2, _width, _height)
    bg:setFillColor(1,1,1) -- This isn't the only white thing... I don't know why
    backgroundGroup:insert(bg)



    -- Add obstacle button
 	local button = display.newRect(uiGroup, 3*display.contentWidth/4, 3*display.contentHeight/4,
 	display.contentWidth/2,display.contentHeight/8)
 	button:setFillColor(0,127,0)
 	button:addEventListener("tap", addObstacle_tapped)
 	local text = display.newText(uiGroup, "add obstacle", 
 		3*display.contentWidth/4, 3*display.contentHeight/4,
 		native.systemFont)
 	text:setFillColor(0,0,0)

 	-- Increase time button
 	local button = display.newRect(uiGroup, display.contentWidth/4, 3*display.contentHeight/4,
 	display.contentWidth/2,display.contentHeight/8)
 	button:setFillColor(127,0,0)
 	button:addEventListener("tap", addTime_tapped)
 	local text = display.newText(uiGroup, "add 1000", 
 		display.contentWidth/4, 3*display.contentHeight/4,
 		native.systemFont)
 	text:setFillColor(0,0,0)


    -- Initialize ui
    score = 0
    time_scale = 1
    total_norm_sec = 0
    scoreText = display.newText(uiGroup, score, _width/2, _height/8, native.systemFont, 36)
    scoreText:setFillColor(0,0,0)

    --drawCheckerboard()
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        util.printMemUsage()
        last_frame_time = system.getTimer()

        -- Initialize level data
        local level = composer.getVariable("level")
        level_data = require ("Levels."..level)

        print("Here we are, playing level ".. level_data.name)
        if level_data.startScore then
            score = level_data.startScore
        else
            score = 0
        end

        update_scoreText()

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        -- Start the physics!
        physics.start()
        physics.setGravity(0,0)
        physics.setDrawMode("normal")
        Runtime:addEventListener("collision", onCollision) -- This should probably move somewhere else but it is here for now
        Runtime:addEventListener("touch", onTouch)

        -- Add borders to Physics
        local borderProperties = {density = 1.0, bounce = 0.2}
        physics.addBody(leftBorder,"static", borderProperties)
        physics.addBody(rightBorder,"static", borderProperties)
        physics.addBody(topBorder,"static", borderProperties)
        physics.addBody(bottomBorder,"static", borderProperties)

        -- Run the intro, then start the game!
        run_intro()
        timer.performWithDelay(1000, start_game)
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
