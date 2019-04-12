if (CLIENT) then return end

api = {}
api.endpoints = {}
api.server = nil

require("bromsock")
include("api/functions.lua")
include("api/host.lua")

api.CreateDatabases()

if (api.server) then
	print("The API server is already being hosted, closing it.")
	api.server:Close()
	api.server = nil
end

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
	if (#args == 0) then
		api.server = api.startServer(8123)
	else
		local port = tonumber(args[1])
		api.server = api.startServer(port)
	end
end)