-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local preference=require( "preference" )

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local background,reloadButton,backButton
local screenW, screenH, screenHalfW, screenHalfH = display.contentWidth,display.contentHeight,display.contentWidth*.5,display.contentHeight*0.5
-- 'onRelease' event listener for playBtn
local topScoreText,displaySavedScores,scoreText,displayScore
local function reloadButtonRelease()
	
	-- go to level1.lua scene
	composer.removeScene( "level1" )
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function backButtonRelease()
	
	-- go to level1.lua scene
	composer.removeScene( "level1" )
	composer.gotoScene( "menu", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	background = display.newImageRect( "lastpage.jpg", screenW, screenH )
	background.anchorX = 0
	background.anchorY = .08
	background.yScale=1.5
	background.x, background.y = 0, 0

	backButton=widget.newButton
	{
		defaultFile = "backegg.png",
		overFile= "backegghover.png",
		onRelease = backButtonRelease,
	}
	backButton.x= screenW-60
	backButton.y= screenH-20

	reloadButton = widget.newButton
	{		
		defaultFile = "reload.png",
		overFile= "reloadhover.png",
		onRelease = reloadButtonRelease,
	}
	reloadButton.x = 50
	reloadButton.y = screenH-20
	-- all display objects must be inserted into group

	topScoreText = display.newText( "HIGHEST SCORE", 20 , 60, "Comic Sans MS", 25 , "center")
	topScoreText:setFillColor(1, 85/255, 85/255)
	topScoreText.x=screenHalfW
	topScoreText.y=screenHalfH-30

	displaySavedScores=display.newText( "0", 20 , 60, "Comic Sans MS", 25 , "center" )
	displaySavedScores:setFillColor(1, 85/255, 85/255)
	displaySavedScores.x=screenHalfW
	displaySavedScores.y=screenHalfH

	scoreText = display.newText( "YOUR SCORE", 20 , 60, "Comic Sans MS", 25 , "center")
	scoreText:setFillColor(1, 85/255, 85/255)
	scoreText.x=screenHalfW
	scoreText.y=displaySavedScores.y+30

	displayScore=display.newText( "0", 20 , 60, "Comic Sans MS", 25 , "center" )
	displayScore:setFillColor(1, 85/255, 85/255)
	displayScore.x=screenHalfW
	displayScore.y=scoreText.y+30
	displayScore.text=event.params.newScore
	
	value=preference.getValue("gameOn")
	if (value==true) then
		value=preference.getValue("savedScores")
		displaySavedScores.text=value
	end

	sceneGroup:insert( background )
	sceneGroup:insert( reloadButton )
	sceneGroup:insert( backButton )
	sceneGroup:insert( topScoreText )
	sceneGroup:insert( displaySavedScores )
	sceneGroup:insert( scoreText )
	sceneGroup:insert( displayScore )
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