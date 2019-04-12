local endpoint = {
	path = "/discord",
	method = "POST",
	whitelist = {
		["82.39.51.21"] = true
	}
}

function endpoint:init()
	print("Discord endpoint loaded!")
end

function endpoint:execute(ip, port, headers, content)
	if (content == nil) then
		return false, "No content provided."
	elseif not (content["author"] and content["message"] and content["role"] and content["role"]["name"] and content["role"]["color"]) then
		return false, "Not all arguments were provided."
	end

	-- Obviously recode this.
	local name = content["author"]
	local message = content["message"]
	local role = content["role"]["name"]
	local final = "(" .. role .. ") " .. name .. ": " .. message
	print(final)

	return true, {["chat"]=final}
end

return endpoint