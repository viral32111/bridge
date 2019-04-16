if (CLIENT) then return end

api = {}
api.server = nil
api.endpoints = {}
api.clients = {}

require("bromsock")
include("api/functions.lua")
include("api/host.lua")
include("api/concommands.lua")

api.CreateDatabases()

local endpointFiles, endpointDirs = file.Find("api/endpoints/*", "LUA")
for _, endpointFile in pairs(endpointFiles) do
	local endpoint = include("api/endpoints/" .. endpointFile)
	api.endpoints[endpoint.path] = endpoint
	print("Loaded API Endpoint: " .. endpoint.path)
end
for _, endpointDir in pairs(endpointDirs) do
	local endpointFiles, _ = file.Find("api/endpoints/" .. endpointDir .. "/*.lua", "LUA")
	for _, endpointFile in pairs(endpointFiles) do
		local endpoint = include("api/endpoints/" .. endpointDir .. "/" .. endpointFile)
		api.endpoints[endpoint.path] = endpoint
		print("Loaded API Endpoint: " .. endpoint.path)
	end
end

hook.Add("InitPostEntity", "initStartHook", function()
	hook.Add("Think", "startAPI", function()
		timer.Simple(1, function()
			api.server = api.startServer(27028)
		end)
		hook.Remove("Think", "startAPI")
	end)
end)