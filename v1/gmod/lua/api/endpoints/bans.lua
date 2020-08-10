local endpoint = {
	method = api.methods.get
}

function endpoint:execute(ip, port, headers, content)
	local result = sql.Query("SELECT * FROM ulib_bans")
	print(tostring(result))

	return false, "Not implemented yet."
end

return endpoint