local endpoint = {
	path = "/addons",
	method = "GET",
	whitelist = {}
}

function endpoint:init()
	print("Addon endpoint loaded!")
end

function endpoint:execute(ip, port, headers, content)
	local addons = {}

	for _, workshop in pairs(engine.GetAddons()) do
		local struct = {
			["name"] = workshop.title,
			["id"] = workshop.wsid,
			["workshop"] = true,
		}
		table.insert(addons, struct)
	end

	local _, dirs = file.Find("garrysmod/addons/*", "BASE_PATH")
	for id, legacy in pairs(dirs) do
		local struct = {
			["name"] = legacy,
			["workshop"] = false,
		}
		table.insert(addons, struct)
	end

	return true, addons
end

return endpoint