local endpoint = {
	path = "/bans",
	method = "GET",
	whitelist = {}
}

function endpoint:init()
	print("Bans endpoint loaded!")
end

function endpoint:execute(ip, port, headers, content)
	return false, "Not implemented yet."
end

return endpoint