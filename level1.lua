-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local widget=require( "widget" )
local preference=require( "preference" )

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
local physicsBody={}

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, screenHalfW, screenHalfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5
local count,totalCount=0,0
local changePanTimer,movingPanTimer,eggFallTimer,warningTimer 
local gameOverFlag,basketFlag,isOnMove,isPaused
local x
local failCount,failIndex,eggIndex
local timeLevel=5000
local backSound,crackSound,eggSound,frySound,goldSound,bombSound
local backSoundChanel,crackSoundChanel,eggSoundChanel,frySoundChanel,goldSoundChanel,bombSoundChanel

-- objects
local egg,brokenEgg,basket,background,grass,pan,by,eggHieght,grenade,score,scoreDisplay,pauseButton
local collisionGroup = display.newGroup( )
local eggsBaskets = {}
local bokenEggList = {}
local failSignList = {}
local eggList = {}

function gameOver(  )
	-- body
	if (gameOverFlag==true) then
		saveScore()
		gameOverFlag=false
		composer.removeScene( "gameOver" )
		composer.gotoScene( "gameOver", {effect="fade", time=500, params = { newScore=score }} )
	end	
end

function pauseGame(  )
	if (isPaused==false) then
		isPaused=true
		pauseButton.x=screenHalfW
		pauseButton.y=screenHalfH-50
		pauseButton.xScale=1.5
		pauseButton.yScale=1.5

		if (changePanTimer~=nil) then
			timer.pause(changePanTimer)
		end
		if (movingPanTimer~=nil) then
			timer.pause(movingPanTimer)	
		end
		if (warningTimer~=nil) then
			timer.pause(warningTimer)
		end
		if (eggFallTimer~=nil) then
			timer.pause(eggFallTimer)	
		end	

		Runtime:removeEventListener( "enterFrame", eachFrameRunning )
		background:removeEventListener( "touch", basketMoves )
		Runtime:removeEventListener( "collision", onGlobalCollision )
		pan:removeEventListener( "tap", onPanClick )
		Runtime:removeEventListener("system",onSystemEvent)

		audio.pause(backSoundChanel)
		audio.pause(frySoundChanel)
		physics.pause( )
	elseif (isPaused==true) then
		isPaused=false	
		pauseButton.x = screenW-30
		pauseButton.y = 0
		pauseButton.xScale = .6
		pauseButton.yScale = .6
		
		audio.resume(backSoundChanel)
		audio.resume(frySoundChanel)
		physics.start( )

		if (changePanTimer~=nil) then
			timer.resume(changePanTimer)
		end
		if (movingPanTimer~=nil) then
			timer.resume(movingPanTimer)	
		end
		if (warningTimer~=nil) then
			timer.resume(warningTimer)
		end
		if (eggFallTimer~=nil) then
			timer.resume(eggFallTimer)	
		end	

		Runtime:addEventListener( "enterFrame", eachFrameRunning )
		background:addEventListener( "touch", basketMoves )
		Runtime:addEventListener( "collision", onGlobalCollision )
		pan:addEventListener( "tap", onPanClick )	
		Runtime:addEventListener("system",onSystemEvent)		
	end
end

local pauseButtonPress = function( event )
	pauseGame()
end

function onSystemEvent( event )
	if (event.type=="applicationSuspend") then
		pauseGame()
	elseif(event.type=="applicationExit")then
	end
end

function drawObjects( )
	background = display.newImageRect( "kitchen.jpg", screenW, screenH )
	background.anchorX = 0
	background.anchorY = .2
	background.yScale=1.5
	background.x, background.y = 0, 0
	egg = display.newImage( "egg.png" )
	egg.x, egg.y = 160, -100
	eggHieght=egg.contentHeight/2
	brokenEgg=display.newImage("broken.png")
	brokenEgg.x=egg.x
	brokenEgg.y=egg.y
	basket = display.newImage( "basket.png" )
	basket.x = screenHalfW
	basket.y = screenH-190
	by=basket.y
	pan=display.newImage( "pan.png" )
	pan.x=screenW-70
	pan.y=screenH-20
	pan.xScale=.7
	pan.yScale=.7
	grenade=display.newImage( "grnade.png" )
	grenade.x, grenade.y= 160, -100
	scoreDisplay = display.newText( "0", 20, 120, "Comic Sans MS", 25 , "center")
	scoreDisplay.x = 40
	scoreDisplay.y = screenH - 60
	scoreDisplay.yScale=1.1
	scoreDisplay:setFillColor( 0, 75/255, 75/255 )
	grass = display.newImageRect( "wood.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	grass.x, grass.y = 0, display.contentHeight-90
	grass.myName="grass"
	pauseButton= widget.newButton
	{		
		defaultFile = "pause.png",
		overFile= "pausehover.png",
		onRelease = pauseButtonPress,
	}
	pauseButton.x = screenW-30
	pauseButton.y = 0
	pauseButton.xScale = .6
	pauseButton.yScale = .6
end

function soundSet(  )
	-- body
	backSound = audio.loadStream( "backmusic.mp3" )
	eggSound = audio.loadSound( "ting.mp3" )
	frySound = audio.loadSound( "fry.mp3" )
	goldSound = audio.loadSound( "gping.mp3" )
	crackSound = audio.loadSound( "crack.mp3" )	
	bombSound = audio.loadSound( "bomb.mp3" )
end
-- function createPhysicsBody(  )
-- 	-- body
-- 	physicsBody["basket"]=
-- 	{
-- 		   {
--                 pe_fixture_id = "", density = 50, friction = 1.0, bounce = 0, 
--                 filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
--                 shape = {   -57.5, 25  ,  -46.5, 28  ,  -54.5, 38  ,  -57, 33  }
--            },
           
--            {
--                 pe_fixture_id = "", density = 50, friction = 1.0, bounce = 0, 
--                 filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
--                 shape = {   69.5, -34  ,  56, 34  ,  51.5, 37.5  ,  46.5, 29  ,  60.5, -40  }
--            },
           
--            {
--                 pe_fixture_id = "", density = 50, friction = 1.0, bounce = 0, 
--                 filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
--                 shape = {   -46.5, 28  ,  -57.5, 25  ,  -68.5, -32  ,  -60.5, -39  }
--            },
           
--            {
--                 pe_fixture_id = "", density = 50, friction = 1.0, bounce = 0, 
--                 filter = { categoryBits = 1, maskBits = 65535, groupIndex = 0 },
--                 shape = {   -46.5, 28  ,  46.5, 29  ,  51.5, 37.5  ,  -54.5, 38  }
--            }

-- 	}
-- end


function eggFall( randomPosition )
	-- body
	if (count>2 and (totalCount + math.random(100))%5==0) then
		egg = display.newImage( "goldenegg.png" )
		egg.x=randomPosition
		egg.y=-100
		physics.addBody( egg, { density=10, friction=.3, radius=15, rotarion=2} )
		egg.myName="goldenegg"
		collisionGroup:insert( egg )
	elseif (totalCount>10 and math.random(100)%5==0) then
		egg = display.newImage( "grnade.png" )
		egg.x=randomPosition
		egg.y=-100
		physics.addBody( egg, { density=10, friction=.3, radius=15, rotarion=2} )
		egg.myName="grenade"
		collisionGroup:insert( egg )
	else
		egg = display.newImage( "egg.png" )
		egg.x=randomPosition
		egg.y=-100
		physics.addBody( egg, { density=10, friction=.3, radius=15, rotarion=2} )
		egg.myName="egg"
		collisionGroup:insert( egg )
	end
	collisionGroup:insert( basket )
end

local eggFallPosition = function ()
	-- body
	local randomPosition=20+math.random( 20,screenW-30 )
	return eggFall(randomPosition)
end


function failShow(  )
	-- body
	failSignList[failIndex]=display.newImage( "fail.png" )
	failSignList[failIndex].x=x
	failSignList[failIndex].y=screenH-10
	collisionGroup:insert(failSignList[failIndex])
	failIndex=failIndex+1
end


function onGlobalCollision( event )
	-- body
	if (event.phase=="began") then
		local name=event.object2.myName
		if (event.object1==grass) then
			if(name=="egg")then
				brokenEgg=display.newImage("broken.png")
				brokenEgg.x=event.object2.x
				brokenEgg.y=event.object2.y
				collisionGroup:insert( brokenEgg )
				transition.to( brokenEgg, {alpha=0, time=1000} )
				audio.play(crackSound)
				x=x+30
				failShow()
				failCount=failCount+1
				if (failCount>3) then
					gameOverFlag=true
				end
			elseif(name=="grenade") then
				score=score+200
				scoreDisplay.text=score
				local tx=event.object2.x
				local ty=event.object2.y
				local explosion=display.newImage( "explodes.png" )
				explosion.x=tx
				explosion.y=ty
				audio.play(bombSound)
				collisionGroup:insert( explosion )
				transition.to( explosion, {time=1500, alpha=0, y=-50} )
			elseif(name=="goldenegg") then
				if (score>50) then
					score=score-50
					scoreDisplay.text=score
				end
				local tx=event.object2.x
				local ty=event.object2.y
				local explosion2=display.newImage( "explosionMagic.png" )
				explosion2.x=tx
				explosion2.y=ty
				collisionGroup:insert( explosion2 )
				transition.to( explosion2, {time=1500, alpha=0, y=-50} )
			end	
			event.object2:removeSelf( )
		elseif (event.object1==basket) then
			--print( event.object2.myName )
			event.object2:removeSelf()
			if (count<6) then
				local tx=event.object1.x
				local ty=event.object1.y
				if (name=="goldenegg") then
					count=0
					local five=display.newImage( "five.png" )
					five.x=tx
					five.y=ty
					audio.play(goldSound)
					collisionGroup:insert( five )
					transition.to( five, {time=1500, alpha=0, y=-50} )
					score=score+500
					scoreDisplay.text=score
				elseif(name=="grenade")then
					audio.play(bombSound)
					gameOverFlag=true
				else
					count=count+1
					local one=display.newImage( "one.png" )
					one.x=tx
					one.y=ty
					audio.play(eggSound)
					collisionGroup:insert( one )
					transition.to( one, {time=1500, alpha=0, y=-80} )
					score=score+10
					scoreDisplay.text=score
				end
				basketFlag=true
				totalCount=totalCount+1	
				isOnMove=false
				levelChange()
		    else
		    	local tx=event.object1.x
				local ty=event.object1.y
				if (name=="goldenegg") then
					count=0
					local five=display.newImage( "five.png" )
					five.x=tx
					five.y=ty
					collisionGroup:insert( five )
					audio.play(goldSound)
					transition.to( five, {time=1500, alpha=0, y=-50} )
					score=score+500
					scoreDisplay.text=score
					basketFlag=true
					isOnMove=false
					levelChange()
				elseif(name=="grenade")then
					audio.play(bombSound)
					gameOverFlag=true
				else
					brokenEgg=display.newImage("broken.png")
					brokenEgg.x=event.object2.x
					brokenEgg.y=event.object1.y+25
					audio.play(crackSound)
					collisionGroup:insert( brokenEgg )
					transition.to( brokenEgg, {alpha=0, time=1000} )
					x=x+30
					failShow()
					failCount=failCount+1
					if (failCount>3) then
						gameOverFlag=true
					end
				end
			end	
		end
	end
end

function setEggFalTimer(  )
	-- body
	timer.cancel(eggFallTimer)	
	eggFallTimer = timer.performWithDelay( timeLevel, eggFallPosition , 0 )
end

function levelChange(  )
	-- body
	if (score>10 and score<=700 ) then
		timeLevel=3000
	elseif(score>700 and score<=1500 ) then
		timeLevel=2000
	elseif(score>1500 and score<=2200 ) then
		timeLevel=1500
	elseif(score>2200 and score<=3000 ) then
		timeLevel=1300
	elseif(score>3000 and score<=4000 ) then
		timeLevel=1000
	elseif(score>4000 and score<=5000 ) then
		timeLevel=700
	elseif(score>5000 and score<=7500 ) then
		timeLevel=500
	elseif(score>7500 and score<=10000 ) then
		timeLevel=400
	elseif(score>10000 ) then
		timeLevel=300
	end

	setEggFalTimer(  )
end

function eachFrameRunning( event )
	-- body
	--print(":O")
	if (isOnMove==false and basketFlag==true) then
		local x=basket.x
		
		if(count<7 and basketFlag==true)then 
			basketChanged()
		end
		
		if(x > 20 and x < screenW-20)  then
			basket.x=x
			if(count>3 and count<7)then
				basket.y=by-(eggHieght/2)+5
			else
				basket.y=by
			end
			px=x	
		end
	end
end

function repeatWarning( event )
	-- body
	basket.alpha=1
	transition.to( basket, {alpha=0, time=1000} )
end

function basketChanged( )
	-- body
	basketFlag=false
	physics.removeBody( basket )
	basket:removeSelf()
	if (warningTimer~=nil) then
			timer.cancel( warningTimer )
	end
	if (count==0) then
		basket=display.newImage( "basket.png" )
	elseif (count==1) then
		basket=display.newImage( "basket1.png" )
	elseif (count==2) then
		basket=display.newImage( "basket2.png" )
	elseif (count==3) then
		basket=display.newImage( "basket3.png" )
	elseif (count==4) then
		basket=display.newImage( "basket4.png" )
	elseif (count==5) then
		basket=display.newImage( "basket5.png" )
	elseif (count==6) then
		basket=display.newImage( "basket6.png" )
		warningTimer=timer.performWithDelay( 1000, repeatWarning, 0)
	end	
	collisionGroup:insert( basket )
	-- physics.addBody( basket,"kinematic",  unpack( physicsBody ["basket"] ) )
	physics.addBody( basket,"kinematic",{density=50, friction=0.3} )
end

local bx,px
function basketMoves( event )
	
	if(event.phase=="began") then
		basket.x0=event.x-basket.x
		--print(basket.x0)
		bx=basket.x0
		isOnMove=true
	end

	if(event.phase=="moved" )then
		if(count>0 and count<7 and basketFlag==true)then 
			basketChanged()
		end
		
		local x=event.x-bx

		if(x > 40 and x < screenW-40)  then
			basket.x=x
			if(count>3 and count<7)then
				basket.y=by-(eggHieght/2)+5
			else
				basket.y=by
			end
			px=x
		end
	end

	-- if (event.phase=="ended" or event.phase=="canceled") then
	-- end
	return true
end


function shakeObject( )
	-- body
	local falg=1
	pan.rotation=0
	if (flag==1) then
		flag=0
		transition.to( pan,{rotation=3,time=500,transition=easing.inOutCubic} )
	else 
		flag=1
		transition.to( pan,{rotation=-3,time=500,transition=easing.inOutCubic} )
	end
end

local isPanChanges=false
function onPanClick( event )
	-- body
	if(count>0 and isPanChanges==false)then
		count=count-1
		if (warningTimer~=nil) then
			timer.cancel( warningTimer )
		end
		basketChanged()
		score=score+100
		scoreDisplay.text=score
		basket.x=px
		if(count>3 and count<7)then
			basket.y=by-(eggHieght/2)+5
		else
			basket.y=by
		end
		local x=pan.x
		local y=pan.y
		pan:removeSelf( )
		frySoundChanel = audio.play(frySound)
		pan=display.newImage( "panegg.png" )
		pan.x=x
		pan.y=y
		pan.xScale=0.7
		pan.yScale=0.7
		collisionGroup:insert( pan )
		pan:removeEventListener( "tap", onPanClick )
		changePanTimer=timer.performWithDelay( 5000, eggPanChanges , 1 )
		movingPanTimer=timer.performWithDelay( 500, shakeObject , 10 )
		isPanChanges=true
	end
end

function eggPanChanges( )
	-- body
	isPanChanges=false
	local x=pan.x
	local y=pan.y
	pan:removeSelf( )
	pan=display.newImage( "pan.png" )
	pan.x=x
	pan.y=y
	pan.xScale=0.7
	pan.yScale=0.7
	collisionGroup:insert( pan )
	pan:addEventListener( "tap", onPanClick )
end

--saving score
function saveScore(  )
	-- body
	value=preference.getValue("gameOn")
	if (value==true) then
		value=preference.getValue("savedScores")
		if (score>value) then
			preference.save{savedScores = score}
			--print( score )
		end
	elseif(value==false)then
		preference.save{gameOn=true}
		preference.save{savedScores = score}
	end
	
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	print( "WHY???????????????????????????????????????????????????" )
	drawObjects()
	--createPhysicsBody()
	soundSet()
	score=0
	
	-- all display objects must be inserted into group

	sceneGroup:insert( background )
	sceneGroup:insert( grass )
	sceneGroup:insert( egg )
	sceneGroup:insert( grenade )
	sceneGroup:insert( brokenEgg )
	sceneGroup:insert( basket )	
	sceneGroup:insert( pan )
	sceneGroup:insert( scoreDisplay )
	sceneGroup:insert( collisionGroup )
	sceneGroup:insert( pauseButton )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	sceneGroup:insert( collisionGroup )
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		count=0
		totalCount=0
		basketFlag=true
		isOnMove=false
		isPanChanges=false
		x=5
		failCount=0
		failIndex=1
		score=0
		isPaused=false

		physics.start()
		
		scoreDisplay.text = score
		backSoundChanel = audio.play(backSound, { loops = -1 })
		
		print("what?")
		physics.addBody( basket,"kinematic" )
		-- physics.addBody( basket,"kinematic",  unpack( physicsBody ["basket"] ) )

		-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
		local grassShape = { -screenHalfW,-10, screenHalfW,-10, screenHalfW,34, -screenHalfW,34 }
		physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
		gameOverFlag=false
		

		print( gameOverFlag )
		--physics.setDrawMode( "hybrid" )
		timer.performWithDelay( 10, gameOver,0 )
		timeLevel=5000
		eggFallTimer = timer.performWithDelay( timeLevel, eggFallPosition , 0 )
		Runtime:addEventListener( "enterFrame", eachFrameRunning )
		background:addEventListener( "touch", basketMoves )
		Runtime:addEventListener( "collision", onGlobalCollision )
		pan:addEventListener( "tap", onPanClick )
		Runtime:addEventListener("system",onSystemEvent)
	end
	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	sceneGroup:insert(collisionGroup)
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)

		for i=1,#failSignList do
			failSignList[i]:removeSelf( )	
		end
		count=0
		totalCount=0
		print( "wow" )
		if (changePanTimer~=nil) then
			timer.cancel(changePanTimer)
		end
		if (movingPanTimer~=nil) then
			timer.cancel(movingPanTimer)	
		end
		if (warningTimer~=nil) then
			timer.cancel(warningTimer)
		end
		if (eggFallTimer~=nil) then
			timer.cancel(eggFallTimer)	
		end	
		audio.stop(backSoundChanel)
		audio.stop(frySoundChanel)
		Runtime:removeEventListener( "enterFrame", eachFrameRunning )
		background:removeEventListener( "touch", basketMoves )
		Runtime:removeEventListener( "collision", onGlobalCollision )
		pan:removeEventListener( "tap", onPanClick )
		Runtime:removeEventListener("system",onSystemEvent)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
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
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene