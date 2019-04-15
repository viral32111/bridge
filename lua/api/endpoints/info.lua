local endpoint = {
	path = "/info",
	method = "GET",
	whitelist = {}
}

local adminGroups = {
	["founder"] = true,
	["manager"] = true,
	["superadmin"] = true,
	["admin"] = true,
	["moderator"] = true,
	["trialmoderator"] = true
}

function endpoint:execute(ip, port, headers, content)
	local tbl = {
		["ip"] = game.GetIPAddress(),
		["hostname"] = GetHostName(),
		["map"] = game.GetMap(),
		["gamemode"] = engine.ActiveGamemode(),
		["uptime"] = CurTime(),
		["maxplayers"] = game.MaxPlayers(),
		["bots"] = {},
		["players"] = {},
		["admins"] = {}
	}

	for _, bot in pairs(player.GetBots()) do
		local struct = {
			["name"] = bot:Nick(),
			["time"] = bot:TimeConnected(),
			["id"] = bot:EntIndex(),
		}
		table.insert(tbl["bots"], struct)
	end

	for _, ply in pairs(player.GetAll()) do
		local struct = {
			["name"] = ply:Nick(),
			["steamid"] = ply:SteamID64(),
			["group"] = ply:GetUserGroup(),
			["time"] = ply:TimeConnected(),
			["id"] = ply:EntIndex(),
		}
		table.insert(tbl["players"], struct)

		if (adminGroups[ply:GetUserGroup()]) then
			table.insert(tbl["admins"], struct)
		end
	end

	return true, tbl
end

return endpoint