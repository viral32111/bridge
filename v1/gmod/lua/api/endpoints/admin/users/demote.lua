local endpoint = {
	method = api.methods.post
}

function endpoint:execute(ip, port, headers, content)
	return false, "Not implemented yet."
end

return endpoint