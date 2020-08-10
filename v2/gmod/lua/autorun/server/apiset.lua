--[[------------------------------------------------
Setup script
------------------------------------------------]]--

-- Listen for events
gameevent.Listen( "player_connect" )
gameevent.Listen( "player_disconnect" )

-- Constant variable to hold the API endpoint URL 
local SEND_STATUS_URL = "https://conspiracyservers.com/api/v1/status"

-- Key for accessing the API
local KEY = "wE7N7JGQW6N3jxZh3enPkFY5WEETzWpCcGuzVbavWKjH2pVV"

-- A buffer that contains the data to be sent
local statusBuffer = {}

-- The base custom community ID for bots
local botBaseCommunityID = 100000

--[[------------------------------------------------
Define HTTP callbacks
------------------------------------------------]]--

-- Success
local function httpSuccess( status, body, headers )

	if status != 201 then

		error( "Received bad status code while sending status to API: " .. status .. " (" .. body .. ")" )

	end

end

-- Failure
local function httpFailure( reason )

	error( "Failed to send status to API because " .. reason )

end

--[[------------------------------------------------
Define helper functions
------------------------------------------------]]--

-- Easily send status data to the API
local function sendStatusToAPI()

	-- JSON encode the data
	local encoded = util.TableToJSON( statusBuffer )

	-- Make a HTTP request
	HTTP( {

		-- Method
		method = "POST",

		-- Target
		url = SEND_STATUS_URL,

		-- Content type
		type = "application/json",

		-- Headers
		headers = {

			-- Accept JSON
			[ "accept" ] = "application/json",

			-- Authentication
			[ "authorization" ] = "Key " .. KEY

		},

		-- Data
		body = encoded,

		-- Callbacks
		success = httpSuccess,
		failed = httpFailure

	} )

end

-- Get a player or bot community ID
local function getCommunityID( plyOrName, steamID, isBot )

	-- Is the first argument a string?
	if type( plyOrName ) == "string" then

		-- Are they a bot?
		if isBot == 1 then

			-- Return the custom bot community ID offset by the bot number
			return tostring( botBaseCommunityID + tonumber( string.sub( plyOrName, 4 ) ) )

		-- They are a regular player
		else

			-- Return the player's community ID converted from their steam ID
			return util.SteamIDTo64( steamID )

		end

	-- The first argument is a player
	else

		-- Are they a bot?
		if plyOrName:IsBot() then

			-- Return the custom bot community ID offset by the bot number
			return tostring( botBaseCommunityID + tonumber( string.sub( plyOrName:Nick(), 4 ) ) )

		-- They are a regular player
		else

			-- Return the player's community ID
			return plyOrName:SteamID64()

		end

	end

end

-- Get a player or bot's real IP address and port
local function getAddress( ipAddress, isBot )

	-- Was nothing provided, is it an error, is it a local IP, or are they a bot?
	if ( ipAddress == nil and isBot == nil ) or ( ipAddress == "Error!" ) or ( string.sub( ipAddress, 8 ) == "192.168." or string.sub( ipAddress, 3 ) == "10." ) or isBot == 1 then

		-- Return the split up server's address
		return string.Explode( ":", game.GetIPAddress() )

	end

	-- Return their split up address
	return string.Explode( ":", ipAddress )

end

-- Remove all players from the buffer by community ID
local function removeAllPlayers( communityID )

	-- Loop through all players in the buffer
	for index = 1, #statusBuffer.players do

		-- Fetch the player structure for this iteration
		local structure = statusBuffer.players[ index ]

		-- Skip if the structure is somehow nil
		if structure == nil then continue end

		-- Is this structure for the player we want to remove?
		if structure.id.community == communityID then

			-- Remove the structure from current players
			statusBuffer.players[ index ] = nil

		end

	end

end

-- Loop through all players with a specified community ID and run a custom function
local function loopThroughAllPlayers( communityID, foundCallback )

	-- Loop through all players in the buffer
	for index = 1, #statusBuffer.players do

		-- Fetch the player structure for this iteration
		local structure = statusBuffer.players[ index ]

		-- Skip if the structure is somehow nil
		if structure == nil then continue end

		-- Is this structure for the current player?
		if structure.id.community == communityID then

			-- Run the found callback
			foundCallback( index, structure )

		end

	end

end

-- Add an initial player structure if one doesn't exist already
local function addPlayerToBufferIfNotExist( dataOrPly )

	-- Current unix timestamp
	local rightNow = os.time()

	-- Placeholders
	local name = nil
	local address = nil
	local communityID = nil
	local userID = nil
	local isBot = nil

	-- Is the first argument a table?
	if type( dataOrPly ) == "table" then

		-- Get their name
		name = dataOrPly.name

		-- Get their IP address and port
		address = getAddress( dataOrPly.address, dataOrPly.bot )

		-- Get their community ID
		communityID = getCommunityID( dataOrPly.name, dataOrPly.networkid, dataOrPly.isbot )

		-- Get their user ID
		userID = dataOrPly.userid

		-- Are they a bot?
		isBot = tobool( dataOrPly.bot )

	-- The first argument is (probably) a player
	else

		-- Get their name
		name = dataOrPly:Nick()

		-- Get their IP address and port
		address = getAddress( dataOrPly:IPAddress(), dataOrPly:IsBot() )

		-- Get their community ID
		communityID = getCommunityID( dataOrPly )

		-- Get their user ID
		userID = dataOrPly:UserID()

		-- Are they a bot?
		isBot = dataOrPly:IsBot()

	end

	-- Loop through all players in the buffer
	for index = 1, #statusBuffer.players do

		-- Fetch the player structure for this iteration
		local structure = statusBuffer.players[ index ]

		-- Skip if the structure is somehow nil
		if structure == nil then continue end

		-- Is this structure for the current player?
		if structure.id.community == communityID then

			-- Prevent further execution
			return

		end

	end

	-- Construct the player structure
	local structure = {

		-- Name
		name = util.Base64Encode( name ),

		-- Address
		address = {

			-- IP
			ip = address[ 1 ],

			-- Port number
			port = tonumber( address[ 2 ] )

		},

		-- IDs
		id = {

			-- Community ID
			community = communityID,

			-- User ID
			user = userID

		},

		-- For when the player finishes loading
		loaded = false,

		-- For when the player has initally spawned
		spawned = false,

		-- Is bot?
		bot = isBot,

		-- Unix timestamps
		timestamps = {

			-- When the player connected
			connected = rightNow

		}

	}

	-- Add the player structure to the buffer
	table.insert( statusBuffer.players, structure )

end

--[[------------------------------------------------
Define hooks callbacks
------------------------------------------------]]--

-- Runs when the server initalises
local function serverInitalise()

	-- Split up the server's IP address and port
	local address = getAddress()

	-- Get the workshop collection console variable
	-- local collectionID = GetConVar( "host_workshop_collection" ):GetString()

	-- Initalise the buffer
	statusBuffer = {

		-- Address
		address = {

			-- IP
			ip = address[ 1 ],

			-- Port number
			port = tonumber( address[ 2 ] )

		},

		-- Hostname
		name = util.Base64Encode( GetHostName() ),

		-- Map
		map = game.GetMap(),

		-- Gamemode,
		gamemode = engine.ActiveGamemode(),

		-- Unix timestamps
		timestamps = {

			-- When the server started
			startup = os.time() - math.Round( CurTime() ),

		},

		-- Tickrate
		--tickrate = math.Round( 1 / engine.TickInterval() ),

		-- Maximum player slots
		slots = game.MaxPlayers(),

		-- Players
		players = {},

		-- Workshop collection ID
		--collection = collectionID != "" and collectionID or nil,

		-- Addons
		-- addons = {},

		-- Mounted games for content
		--mounted = {}

	}

	-- Loop through all loaded workshop addons
	--[[
	for index, addon in ipairs( engine.GetAddons() ) do

		-- Add the addon to the buffer
		table.insert( statusBuffer.addons, {

			-- This is a workshop addon
			workshop = true,

			-- The workshop addon's ID
			id = addon.wsid

		} )

	end

	-- Get a list of legacy addons
	local _, legacyAddons = file.Find( "addons/*", "MOD" )

	-- Loop through all loaded workshop addons
	for index, addon in ipairs( legacyAddons ) do

		-- Add the addon to the buffer
		table.insert( statusBuffer.addons, {

			-- This is a legacy addon
			workshop = false,

			-- The legacy addon's name
			name = addon

		} )

	end
	]]

	-- Loop through all available games
	--[[for index, game in ipairs( engine.GetGames() ) do

		-- Skip games which aren't mounted
		if game.mounted == false then continue end

		-- Add the game's depot ID to the buffer
		table.insert( statusBuffer.mounted, game.depot )

	end]]

end

-- Runs when the server finishes loading
local function serverFinishLoading()

	-- Remove the hook so it doesn't run again
	hook.Remove( "Think", "apiServerFinishLoading" )

	-- Send the latest status in a few seconds
	timer.Create( "sendBufferSoon", 5, 1, sendStatusToAPI )

end

-- Runs when the server is about to shutdown/switch map
local function serverShutdown()

	-- Set the shutdown timestamp
	statusBuffer.timestamps.shutdown = os.time()

	-- Send it right now!
	sendStatusToAPI()

end

-- Runs when a player connects
local function playerConnect( data )

	-- Get their community ID
	local communityID = getCommunityID( data.name, data.networkid, data.isbot )

	-- Remove every player with this community ID in case there are any duplicates or dangling ones
	removeAllPlayers( communityID )

	-- Add them to the buffer
	addPlayerToBufferIfNotExist( data )

	-- Send it to the server soon
	timer.Create( "sendBufferSoon", 5, 1, sendStatusToAPI )

end

-- Runs when a player initially spawns
local function playerInitialSpawn( ply )

	-- Get their community ID
	local communityID = getCommunityID( ply )

	-- Get the current unix timestamp
	local rightNow = os.time()

	-- Have they loaded (yes if a bot)
	local isLoaded = ply:IsBot()

	-- Add them to the buffer if they don't already exist in it (such as when the map changes and PlayerConnect is never called!)
	addPlayerToBufferIfNotExist( ply )

	-- Loop through all players in the buffer with this community ID
	loopThroughAllPlayers( communityID, function( index, structure )

		-- Set the spawned unix timestamp
		structure.timestamps.spawned = rightNow

		-- Set as spawned
		structure.spawned = true

		-- Set as finished loading
		structure.loaded = isLoaded

	end )

	-- Send it to the server soon
	timer.Create( "sendBufferSoon", 5, 1, sendStatusToAPI )

end

-- Runs when a player finishes loading
local function playerFinishLoading( ply )

	-- Get their community ID
	local communityID = getCommunityID( ply )

	-- Get the current unix timestamp
	local rightNow = os.time()

	-- Loop through all players in the buffer with this community ID
	loopThroughAllPlayers( communityID, function( index, structure )

		-- Set the spawned unix timestamp
		structure.timestamps.loaded = rightNow

		-- Set as finished loading
		structure.loaded = true

	end )

	-- Send it to the server soon
	timer.Create( "sendBufferSoon", 5, 1, sendStatusToAPI )

end

-- Runs when a playger disconnects
local function playerDisconnect( data )

	-- Get their community ID
	local communityID = getCommunityID( data.name, data.networkid, data.isbot )

	-- Remove every player with this community ID in case there are any duplicates or dangling ones
	removeAllPlayers( communityID )

	-- Send it to the server soon
	timer.Create( "sendBufferSoon", 5, 1, sendStatusToAPI )

end

--[[------------------------------------------------
Register hooks
------------------------------------------------]]--

-- For when the server initalises
hook.Add( "InitPostEntity", "apiServerInitalise", serverInitalise )

hook.Add( "Think", "apiServerFinishLoading", serverFinishLoading )

-- For when the server shuts down/switches map
hook.Add( "ShutDown", "apiServerShutdown", serverShutdown )

-- For when a player connects
hook.Add( "player_connect", "apiPlayerConnect", playerConnect )

-- For when a player initially spawns
hook.Add( "PlayerInitialSpawn", "apiPlayerInitialSpawn", playerInitialSpawn )

-- For when a player finishes loading
hook.Add( "PlayerFinishedLoading", "apiPlayerFinishedLoading", playerFinishLoading )

-- For when a player disconnects
hook.Add( "player_disconnect", "apiPlayerDisconnect", playerDisconnect )
