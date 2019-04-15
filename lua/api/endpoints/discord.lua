local endpoint = {
	path = "/discord",
	method = "POST",
	whitelist = {
		["82.39.51.21"] = true
	}
}

function endpoint:execute(ip, port, headers, content)
	if (content == nil) then
		return false, "No content provided."
	elseif not (content["author"] and content["message"] and content["role"] and content["role"]["name"] and content["role"]["color"]) then
		return false, "Not all arguments were provided."
	elseif (discordToChat == nil) then
		return false, "The discord relay is offline."
	end

	local name = content["author"]
	local message = content["message"]
	local role = content["role"]["name"]
	local colorTbl = content["role"]["color"]
	local color = Color(colorTbl[1], colorTbl[2], colorTbl[3])

	discordToChat(name, message, role, color)

	return true, {["name"]=name,["message"]=message,["role"]=content["role"]}
end

return endpoint