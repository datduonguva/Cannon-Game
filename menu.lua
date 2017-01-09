-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local highScore = 0
local playCount = 0

-- include Corona's "widget" library
local widget = require "widget"
local path = system.pathForFile( "myfile.txt", system.DocumentsDirectory )
local path2 = system.pathForFile( "myfile2.txt", system.DocumentsDirectory )
local file, errorString = io.open( path, "r" )
local file2, errorString2 = io.open( path2, "r" )
if not file then
    -- Error occurred; output the cause
    print( "File error: " .. errorString )
else
	highScore = file:read( "*a" )
    io.close( file )
end

file = nil

if not file2 then
    -- Error occurred; output the cause
    print( "File error: " .. errorString2 )
else
	playCount = tonumber(file2:read( "*a" ))
    io.close( file2 )
end

file2 = nil

local ads = require( "ads" )

local appID = "ca-app-pub-4101986457162856/9760334522"

 
local adProvider = "admob"


local function adListener( event )
	local i = math.random(1, 8)

    if ( i == 1 and ads.isLoaded("interstitial") ) then
		
		ads.show("interstitial")
		
	end	
end
 
ads.init( adProvider, appID, adListener )
ads.load( "interstitial")



local scoreText

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.removeScene("level1")
	composer.gotoScene( "level1", "fade", 100 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "background1.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- create/position logo/title image on upper-half of the screen
	--local titleLogo = display.newImageRect( "logo.png", display.actualContentWidth*0.3, display.actualContentHeight*0.3 )
	--titleLogo.x = display.contentCenterX
	--titleLogo.y = display.actualContentHeight*0.7
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = display.newImageRect("play.png", 0.3*display.actualContentWidth, 0.3*display.actualContentHeight)
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentCenterY*1.5
	playBtn:addEventListener("touch", onPlayBtnRelease)
	
	scoreText = display.newText("",display.contentCenterX, display.contentCenterY*0.5, native.systemFont, display.contentCenterY*0.2)
	scoreText.text = "Highest Score: "..highScore
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( scoreText)
	
	sceneGroup:insert( playBtn )
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
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene