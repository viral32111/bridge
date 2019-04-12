local endpoint = {
	path = "/admins",
	method = "GET",
	whitelist = {}
}

function endpoint:init()
	print("Admins endpoint loaded!")
end

function endpoint:execute(ip, port, headers, content)
	return false, "Not implemented yet."
end

return endpoint