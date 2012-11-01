GGRating
============

GGRating makes it very easy to include a nag-screen or popup in your app to 
solicit ratings and reviews from your users.

Basic Usage
-------------------------

##### Require the code
```lua
local GGRating = require( "GGRating" )
```

##### Create your Rating object passing in your apps id, the market the game is in, the ask frequency, alert paramaters and optional listener
```lua
local listener = function( event )
	print( event.phase )
end

local alert = 
{
	title = "Rate App?",
	caption = "Would you like to rate the app?", 
	buttons = { "Yes", "Not Yet", "Never" }
}

local rating = GGRating:new( 000000000, GGRating.Market.Apple, 5, alert, listener )
--local rating = GGRating:new( com.company.game, GGRating.Market.Google, 10, alert, listener )
```

##### Create your Rating object passing in your apps id, the market the game is in, the ask frequency, alert callback and optional listener
```lua
local listener = function( event )
	print( event.phase )
end

local onAlert = function()
	-- This is where you would display your own request dialog
end

local rating = GGRating:new( 000000000, GGRating.Market.Apple, 5, onAlert, listener )
```

##### Make a request to rate the app. Ask every time you get to a point where you would be happy for the player to be
nagged, for instance after completing a level or getting a new high score.
The request will only get presented to the player when this function has been called the required number of times.
```lua
rating:askToRate()
```

##### Manually set a flag to never make sure the player is never prompted.
```lua
rating:neverRate()
```

##### Reset the rating data
```lua
rating:reset()
```

##### Destroy the Rating object
```lua
rating:destroy()
rating = nil
```

Update History
-------------------------

##### 0.1
Initial release