local endpoint = {
	method = api.methods.post
}

function endpoint:execute(ip, port, headers, content)
	if (content == nil) then
		return false, "No content provided."
	elseif not (content.author and content.command) then
		return false, "Not all arguments were provided."
	end

	game.ConsoleCommand(content.command .. "\n")

	print(content.author .. " remotely executed command '" .. content.command .. "'.")

	return true, {}
end

return endpoint