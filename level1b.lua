-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene() -- this is the main scene

--star physics engine and stop right away to add body




-- include Corona's "physics" library
local physics = require "physics"

physics.start()
physics.setGravity(0,60)

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local halfH = display.actualContentHeight/2
-- constants----------------------------------------------------------------------------------------
local target_width_scale = 1.0/40
local target_height_scale = 6.0/40
local target_velocity_min = 1
local target_velocity_max = 2.5

local blocker_height_scale = 10.0/40
local blocker_width_scale = 1.0/40

local ball_radius_scale = 1.0/40
local ball_velocity_scale = 2.0
--variables---------------------------------
local wallTable = {}
local isFire = 0
local timeLeftText
local timeleft = 10.0000
local gameLoopTimer
local timeStart = 0
local timeUpdate
local blocker
local ball

local doneText
local done = 0

local fps = 30
local blocker_speed_scale = 3
local totalDistance = blocker_height_scale*screenH*blocker_speed_scale
local deltaDistance = totalDistance/fps
local n = 0
local numberofTick = screenH*(1-blocker_height_scale)/deltaDistance


local mainGroup
local backGroup
local uiGroup
--------------------------------------------


--FUNCTIONS------------------------------------------

local function fireBall(group,x, y, x_touch, y_touch)
	if (isFire == 0) then
		ball = display.newImageRect(group,"ball.png", ball_radius_scale*screenW*2, ball_radius_scale*screenW*2 )
		ball.x, ball.y = x, y
		physics.addBody(ball, "dynamic",{ density=1.0, friction=0, bounce=0.3 })
		local angle = math.atan2(y-y_touch, x_touch-x)
		ball:setLinearVelocity(ball_velocity_scale*screenW*math.cos(angle), -ball_velocity_scale*screenW*math.sin(angle))
		ball.myName = "ball"
		isFire = 1
	end
end

local function createWall(group, x)
	local wall  = display.newImageRect(group,"target_pic.png", target_width_scale*screenW, target_height_scale*screenH)
	wall.x = x
	wall.y = screenH/2
	physics.addBody(wall, {density = 10, friction = 50, bounce = 1})
	wall.gravityScale = 0

	wall.myName = "wall"
	wall.angularveDamping = 3000
	wall:setLinearVelocity(0.0, math.pow(-1, math.random(1,2))*(math.random()*(target_velocity_max-target_velocity_min)+target_velocity_min)*screenH)
	table.insert(wallTable, wall)
	return wall
end

---------





local function updateText()
	timeUpdate = system.getTimer()
	timeLeftText.text = ""..string.format("Time left: %5.2f", timeleft)
	doneText.text = "Points: "..done
end

local function endGame()
	composer.removeScene("menu")
	composer.gotoScene("menu")

end


local function gameLoop()

	timeUpdate = system.getTimer()
	timeleft = timeleft- (timeUpdate- timeStart)/1000.0
	if timeleft <0 then
		endGame()
	end
	updateText()
	timeStart = timeUpdate
	
end



function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	
	mainGroup = display.newGroup()
	backGroup = display.newGroup()
	uiGroup = display.newGroup()

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newImageRect(backGroup,"background1.png", screenW, screenH )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	background:setFillColor(0.8)
	local top = display.newRect(mainGroup,screenW/2, -2, screenW, 3)
	local bottom = display.newRect(mainGroup, screenW/2, screenH+2, screenW, 3)
	local rightedge = display.newRect(mainGroup, screenW+2, screenH/2, 3, screenH)
	
	physics.addBody(rightedge, "static")
	physics.addBody(top,"static")
	physics.addBody(bottom,"static")
	top.myName = "top"
	bottom.myName = "bottom"
	rightedge.myName = "rightedge"
	
	blocker = display.newImageRect(mainGroup, "blocker.png", blocker_width_scale*screenW, blocker_height_scale*screenH)
	blocker.anchorX, blocker.anchorY = 0, 0
	blocker.x = screenW*0.5
	blocker.y = 0
	physics.addBody(blocker, "static")
	blocker.myName = "blocker"
	
	local function backgroundtouch(motion)
		local touchx= motion.x;
		local touchy = motion.y;
		local ball = fireBall(mainGroup,screenW*ball_radius_scale+1,screenH-ball_radius_scale*screenW-1, touchx,touchy)
		
		
	end
	background:addEventListener("tap", backgroundtouch)
	for count =1, 8, 1 do
		local wall = createWall(mainGroup,(0.55+ count*target_width_scale*2)*screenW)
	end
	
	timeLeftText = display.newText(uiGroup, "", 0, screenH*0.03, native.systemFont, screenH*0.08)
	timeLeftText:setFillColor( 1, 1, 3 )
	timeLeftText.anchorX = 0
	timeLeftText.anchorY = 0
	
	doneText = display.newText(uiGroup, "Points: ", 0, screenH*0.12, native.systemFont, screenH*0.08)
	doneText:setFillColor(1, 1, 1)
	doneText.anchorX, doneText.anchorY = 0, 0
	
	
	
	
	
	-- all display objects must be inserted into group
	sceneGroup:insert( backGroup )
	sceneGroup:insert( mainGroup )
	sceneGroup:insert( uiGroup )
	
	
	
end




local function onCollision(event)
	local obj1 = event.object1
	local obj2 = event.object2
	
	if( obj1.myName == "wall") then
		if(obj2.myName == "top" or obj2.myName =="bottom") then
			for n = #wallTable, 1, -1 do
				if wallTable[n] == obj1 then
					local vx, vy =wallTable[n]:getLinearVelocity()
					wallTable[n]:setLinearVelocity(0,vy)
					wallTable[n].angularvelocity = 0
					break
				end
			end
		else
			for n = #wallTable, 1, -1 do
				if wallTable[n] == obj1 then
					display.remove(obj1)
					display.remove(obj2)
					isFire = 0
					table.remove(wallTable, n)
					timeleft = timeleft + 2
					break
				end
			end
			
		end
		
	elseif(obj2.myName=="wall") then
		if(obj1.myName == "top" or obj1.myName =="bottom") then
			for n = #wallTable, 1, -1 do
				if wallTable[n] == obj2 then
					local vx, vy =wallTable[n]:getLinearVelocity()
					wallTable[n]:setLinearVelocity(0,vy)
					wallTable[n].angularvelocity = 0
					break
				end
			end
		else
			for n = #wallTable, 1, -1 do
				if wallTable[n] == obj2 then
					display.remove(obj1)
					display.remove(obj2)
					isFire = 0
					table.remove(wallTable, n)
					
					break
				end
			end
		end
	end
	
	
	if(obj1.myName =="ball" and (obj2.myName =="top" or obj2.myName == "bottom" or obj2.myName =="rightedge")) then
		display.removal(obj1)
		isFire = 0
	elseif( obj2.myName =="ball" and (obj1.myName =="top" or obj1.myName == "bottom" or obj1.myName =="rightedge")) then
		display.remove(obj2) 
		isFire = 0
	end
	
	
	
end

local function enterFrame()
	n = n+1
	if (n<numberofTick) then
		blocker:translate(0, deltaDistance)
	elseif n == numberofTick then
		blocker.y =screenH*(1-blocker_height_scale)
	elseif(n < 2*numberofTick) then
		blocker:translate(0,-deltaDistance)
	elseif(n == 2*numberofTick) then
		blocker.y = 0
		n = 0
	end	
	
	if isFire == 1 then
		if ball.x <0 then
			display.remove(ball)
			isFire =0
		end
	end
	
end



function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
	
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		timeleft = 10.000
		timeStart = system.getTimer()
		Runtime:addEventListener("preCollision", onCollision)
		gameLoopTimer = timer.performWithDelay(100, gameLoop,0)
		Runtime:addEventListener("enterFrame", enterFrame)
		--Runtime:addEventListener("preCollision", onPreCollision)
		--Runtime:addEventListener("postCollision", onCollision)
		
	
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
		Runtime:removeEventListener("preCollision",onCollision)
		Runtime:removeEventListener("enterFrame", enterFrame)
		physics.stop()
		timer.cancel(gameLoopTimer)
		
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
	for n = #wallTable, 1, -1 do
			display.remove(wallTable[n])
			table.remove(wallTable, n)
	end
	display.remove(top)
	display.remove(bottom)
	display.remove(rightedge)
	display.remove(background)
	display.remove(blocker)
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene