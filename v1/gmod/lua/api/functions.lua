function api.GetEndpoints()
	local directories = {}
	local endpoints = {}

	local function findDirectories(path)
		local files, dirs = file.Find(path .. "/*", "LUA")
		for _, dir in pairs(dirs) do
			table.insert(directories, dir)
			findDirectories(path .. "/" .. dir)
		end
		for _, file in pairs(files) do
			table.insert(endpoints, path .. "/" .. file)
		end
	end
	findDirectories("api/endpoints")

	return endpoints
end

function api.CreateDatabases()
	sql.Query("CREATE TABLE bannedIPs (IPAddress VARCHAR(15) NOT NULL PRIMARY KEY, SteamID VARCHAR(24))")
end

function api.IsIPBanned(ipAddress)
	local result = sql.Query("SELECT * FROM bannedIPs WHERE IPAddress='" .. ipAddress .. "'")
	if (result != nil) then
		return true
	else
		return false
	end
end

function api.BanIP(ipAddress)
	local result = sql.Query("INSERT INTO bannedIPs (IPAddress) VALUES ('" .. ipAddress .. "')")
	if (result == nil) then
		print("Banned IP: " .. ipAddress)
		return true
	else
		print("Cannot ban IP: " .. ipAddress .. ", already banned.")
		return false
	end
end

function api.UnbanIP(ipAddress)
	local result = sql.Query("DELETE FROM bannedIPs WHERE IPAddress='" .. ipAddress .. "'")
	print("Unbanned IP: " .. ipAddress)
end