local endpoint = {
	path = "/bans",
	method = "GET",
	whitelist = {}
}

function endpoint:execute(ip, port, headers, content)
	return false, "Not implemented yet."
end

return endpoint