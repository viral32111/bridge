if (CLIENT) then return end

api = {}
api.endpoints = {}
api.server = nil

require("bromsock")
include("api/functions.lua")
include("api/host.lua")
include("api/concommands.lua")

api.CreateDatabases()

local endpointFiles, _ = file.Find("api/endpoints/*.lua", "LUA")
for _, endpointFile in pairs(endpointFiles) do
	local endpoint = include("api/endpoints/" .. endpointFile)
	api.endpoints[endpoint.path] = endpoint
	print("Loaded API Endpoint: " .. endpoint.path)
end

hook.Add("Think", "startAPI", function()
	timer.Simple(1, function()
		api.server = api.startServer(27108)
	end)
	hook.Remove("Think", "startAPI")
end)