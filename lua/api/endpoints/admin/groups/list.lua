local endpoint = {
	method = api.methods.get
}

function endpoint:execute(ip, port, headers, content)
	return false, "Not implemented yet."
end

return endpoint