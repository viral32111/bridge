local endpoint = {
	path = "/admins",
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

function endpoint:init()
	print("Admins endpoint loaded!")
end

function endpoint:execute(ip, port, headers, content)
	if (not ULib) then
		return false, "ULX & ULib are not installed on the server."
	end
	
	local admins = {}

	for steamid, user in pairs(ULib.ucl.users) do
		local steamid = util.SteamIDTo64(steamid)
		local ply = player.GetBySteamID64(steamid)
		local struct = {
			["name"] = user["name"],
			["steamid"] = steamid,
			["group"] = user["group"],
			["online"] = (ply != false)
		}
		table.insert(admins, struct)
	end

	return true, admins
end

return endpoint