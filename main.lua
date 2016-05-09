-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"
local preference=require( "preference" )

display.setStatusBar( display.HiddenStatusBar )

if(preference.getValue("gameOn")==nil) then
	preference.save{gameOn=false}
end

-- load menu screen
composer.gotoScene( "menu" )