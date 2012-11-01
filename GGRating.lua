-- Project: GGRating
--
-- Date: November 1, 2012
--
-- Version: 0.1
--
-- File name: GGRating.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Update History:
--
-- 0.1 - Initial release
--
-- Comments: 
-- 
--		GGRating makes it very easy to include a nag-screen or popup in your app to 
--		solicit ratings and reviews from your users.
--
-- Copyright (C) 2012 Graham Ranson, Glitch Games Ltd.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge, 
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------------------------------------

local GGRating = {}
local GGRating_mt = { __index = GGRating }

local json = require( "json" )

GGRating.Market = {}
GGRating.Market.Apple = 1
GGRating.Market.Google = 2
GGRating.Market.Amazon = 3
GGRating.Market.Nook = 4

--- Initiates a new GGRating object.
-- @param appID The id of the app.
-- @param market The market the app is in. Choices are GGRating.Market.Apple, GGRating.Market.Google, GGRating.Market.Amazon and GGRating.Market.Nook 
-- @param askFrequency The amount of times GGRating:askToRate() needs to be called before the prompt is shown.
-- @param alert	Either a table containing 'title', 'caption' and 'buttons' or a callback function.
-- @param listener A listener function to be called on specific events.
-- @return The new object.
function GGRating:new( appID, market, askFrequency, alert, listener )
    
    local self = {}
    
    setmetatable( self, GGRating_mt )
    
    self.appID = appID
    self.market = market
    self.askFrequency = askFrequency or 10
    self.alert = alert
    self.listener = listener
    
    self.hasRated = false
    self.canRate = true
    self.currentCheckCount = 0
    
    self:load()
    
    return self
    
end

--- Ask for the user to rate the app. Will only actually ask the player if the conditions are right.
function GGRating:askToRate()
	
	if self.hasRated then
		return
	end
	
	if not self.canRate then
		return
	end
	
	local onSubmit = function( event )
		if event.action == "clicked" then
			if event.index == 1 then -- Yes
				self:rate()
			elseif event.index == 2 then -- No
				
			elseif event.index == 3 then -- Never
				self:neverRate()
			end
		end
	end
	
	self.currentCheckCount = self.currentCheckCount + 1
	
	if self.currentCheckCount >= self.askFrequency then
	
		if self.alert then
			
			if type( self.alert ) == "table" then
				native.showAlert( self.alert.title, self.alert.caption, self.alert.buttons, onSubmit )
			elseif type( self.alert ) == "function" then
				self.alert()
			end
			
		end
		
		if self.listener then
			self.listener{ phase = "rateRequested" }
		end
		
		self.currentCheckCount = 0
		
	end
	
	self:save()
	
end

--- Set a flag to state that the player should never be asked to rate the app.
function GGRating:neverRate()

	self.canRate = false
	if self.listener then
		self.listener{ phase = "neverRate" }
	end
	
	self:save()
	
end

--- Open the store to allow the player to rate the app.
function GGRating:rate()

	if self.market == GGRating.Market.Apple then
		system.openURL( "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" .. self.appID )
	elseif self.market == GGRating.Market.Google then
		system.openURL( "https://play.google.com/store/apps/details?id=" .. self.appID )
	elseif self.market == GGRating.Market.Amazon then
		system.openURL( "http://www.amazon.com/product-reviews/" .. self.appID )
	elseif self.market == GGRating.Market.Nook then
		--system.openURL( )
		print( "Any one know the rate link for the Nook market?" )
	end
	
	self.hasRated = true
	if self.listener then
		self.listener{ phase = "rated" }
	end
	
	self:save()
	
end

--- Resets the Rating object.
function GGRating:reset()

	os.remove( system.pathForFile( "rate.dat", system.DocumentsDirectory ) )
	
	self.hasRated = false
	self.canRate = true
	if self.listener then
		self.listener{ phase = "reset" }
	end
	
	self:save()
	
end

--- Saves the Rating object data to disk. Called internally.
function GGRating:save()
   
	local data = 
	{ 
		hasRated = self.hasRated, 
		canRate = self.canRate,
		currentCheckCount = self.currentCheckCount 
	}

	local path = system.pathForFile( "rate.dat", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	
	if file then
		file:write( json.encode( data ) )
		io.close( file )
		file = nil
	end
	
end

--- Loads the Rating object data from disk. Called internally.
function GGRating:load()

	local path = system.pathForFile( "rate.dat", system.DocumentsDirectory )
	local file = io.open( path, "r" )
	
	if file then
	
		local data = json.decode( file:read( "*a" ) )
		io.close( file )
		
		if data then
			self.hasRated = data.hasRated
			self.canRate = data.canRate
			self.currentCheckCount = data.currentCheckCount 
		end
		
	end
	
end

--- Destroys the Rating object.
function GGRating:destroy()
	self.hasRated = nil
    self.canRate = nil
    self.alertParams = nil
    self.askFrequency = nil
    self.currentCheckCount = nil
end

return GGRating