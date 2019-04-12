if (CLIENT) then return end

api = {}
api.endpoints = {}
api.server = nil

require("bromsock")
include("api/functions.lua")
include("api/host.lua")

api.CreateDatabases()

local endpointFiles, _ = file.Find("api/endpoints/*.lua", "LUA")
for _, endpointFile in pairs(endpointFiles) do
	local endpoint = include("api/endpoints/" .. endpointFile)
	api.endpoints[endpoint.path] = endpoint
	endpoint:init()
	print("Loaded API Endpoint: " .. endpoint.path)
end

hook.Add("InitPostEntity", "startAPI", function()
	timer.Simple(1, function()
		api.server = api.startServer(8123)
	end)
end)

concommand.Add("api_startserver", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	print("Started API server.")

	if (#args == 0) then
		api.server = api.startServer(8123)
	else
		local port = tonumber(args[1])
		api.server = api.startServer(port)
	end
end)

concommand.Add("api_stopserver", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	if (api.server) then
		print("Stopped API server.")
		api.server:Close()
		api.server = nil
	else
		print("API server not running.")
	end
end)