api = api or {
	host = nil,
	endpoints = {},
	clients = {},
	methods = {
		get = 1,
		post = 2
	},
	servers = {
		sandbox = {name="Sandbox", ip="185.44.78.69", port=27018},
		spacebuild = {name="Spacebuild", ip="89.34.96.23", port=27108},
		testing = {name="Testing Server", ip="192.168.0.2", port=27018},
		alex = {name="Alex's Server", ip="192.168.1.90", port=27019}
	},
	whitelist = {
		["82.39.51.21"] = true,
		["185.141.207.138"] = true,
		["192.168.0.2"] = true,
		["192.168.0.3"] = true,
		["192.168.1.90"] = true
	}
}
api.server = api.servers.testing

if (api.host) then
	print("Stopped API server.")
	api.host:Close()
	api.host = nil
end

include("api/functions.lua")
include("api/host.lua")
include("api/concommands.lua")

api.CreateDatabases()

for _, path in pairs(api.GetEndpoints()) do
	local endpoint = include(path)
	local path = string.sub(path, 14, string.len(path)-4)
	api.endpoints[path] = endpoint
	print("Loaded API Endpoint: " .. path)
end

hook.Add("Think", "startAPI", function()
	local port = api.server.port

	timer.Simple(1, function()
		api.host = api.startHost(port)
	end)
	hook.Remove("Think", "startAPI")
end)