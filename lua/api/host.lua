require("bromsock")

local function packetToTable(packet)
	local packetTbl = {headers={}, content=nil}
	local raw = packet:ReadStringAll()
	local lines = string.Explode("\r\n", raw)

	-- Method and Endpoint
	local startLine = string.Explode(" ", lines[1])
	packetTbl.method = startLine[1]
	packetTbl.endpoint = startLine[2]
	table.remove(lines, 1)
	
	-- Headers
	for _, line in pairs(lines) do
		local header = string.Explode(": ", line)
		local name, value = header[1], header[2]
		packetTbl.headers[name] = value
	end

	-- Content
	local length = packetTbl.headers["Content-Length"] or nil
	if (length != nil) then
		local json = string.Trim(packet:ReadString(length+1))
		packetTbl.content = util.JSONToTable(json)
	end
	
	return packetTbl
end


local statusCodes = {
	["200"] = "OK",
	["400"] = "Bad Request",
	["403"] = "Forbidden",
	["404"] = "Not Found",
	["405"] = "Method Not Allowed",
}
local function easyPacket(code, message)
	local code = tostring(code)
	local json = util.TableToJSON({["success"]=(code == "200"), ["message"]=message})
	local packet = BromPacket()
	packet:WriteLine("HTTP/1.1 " .. code .. " " .. statusCodes[code])
	packet:WriteLine("Server: Conspiracy Servers")
	packet:WriteLine("Content-Type: application/json")
	packet:WriteLine("Content-Length: " .. string.len(json))
	packet:WriteLine("")
	packet:WriteLine(json)
	return packet
end

function api.startServer(port)
	if (api.server) then
		print("The API server is already being hosted.")
		return
	end

	local server = BromSock()

	if (not server:Listen(port)) then
		print("API server failed to listen on port " .. port)
		return
	else
		print("API server listening on port " .. port)
	end
	
	server:SetCallbackAccept(function(server, client)
		client:SetCallbackDisconnect(function(socket)
			local address = socket:GetIP() .. ":" .. socket:GetPort()
			print(address .. " -> Disconnected.")
		end)

		-- Announce an incoming connection
		local clientIP = client:GetIP()
		local address = clientIP .. ":" .. client:GetPort()
		print(address .. " -> Incoming connection.")

		-- Check if they are banned from using the API
		if (api.IsIPBanned(clientIP)) then
			print(address .. " is banned from using the API.")
			local ezPacket = easyPacket(403, "You are banned from using the API.")
			client:Send(ezPacket, true)
			client:Disconnect()
			return
		end

		client:SetCallbackReceive(function(socket, packet)
			local didError, details = pcall(function()
				local clientIP, clientPort = socket:GetIP(), socket:GetPort()
				local address = clientIP .. ":" .. clientPort

				local packet = packetToTable(packet)
				print(packet.method, packet.endpoint, packet.content)

				-- Check if the endpoint exists
				if (not api.endpoints[packet.endpoint]) then
					print(address .. " attempted to access an invalid endpoint.")
					local ezPacket = easyPacket(404, "The requested endpoint doesn't exist.")
					socket:Send(ezPacket, true)
					socket:Disconnect()
					return
				end

				local endpoint = api.endpoints[packet.endpoint]

				-- Are they whitelisted?
				if (#endpoint.whitelist >= 1) and (not endpoint.whitelist[clientIP]) then
					print(address .. " is not permitted to access to requested endpoint.")
					local ezPacket = easyPacket(403, "You are not permitted to use this endpoint.")
					socket:Send(ezPacket, true)
					socket:Disconnect()
					return
				end

				-- Correct method?
				if (packet.method != endpoint.method) then
					print(address .. " attempted to access an endpoint with the incorrect method.")
					local ezPacket = easyPacket(405, "You cannot use this method to access this endpoint.")
					socket:Send(ezPacket, true)
					socket:Disconnect()
					return
				end

				-- Execute the endpoint
				local result, extra = endpoint:execute(clientIP, clientPort, packet.headers, packet.content)
				if (result) then
					if (extra == nil) then
						local ezPacket = easyPacket(200, "Success.")
						socket:Send(ezPacket, true)
					elseif (type(extra) == "string") then
						local ezPacket = easyPacket(200, extra)
						socket:Send(ezPacket, true)
					else
						local tbl = {["success"]=true,["message"]="Success",["response"]=extra}
						local json = util.TableToJSON(tbl)
						local returnPacket = BromPacket()
						returnPacket:WriteLine("HTTP/1.1 200 OK")
						returnPacket:WriteLine("Server: Conspiracy Servers")
						returnPacket:WriteLine("Content-Type: application/json")
						returnPacket:WriteLine("Content-Length: " .. string.len(json))
						returnPacket:WriteLine("")
						returnPacket:WriteLine(json)
						socket:Send(returnPacket, true)
					end
					socket:Disconnect()
					return
				else
					if (extra == nil) then
						local ezPacket = easyPacket(400, "The endpoint denied your request with no further details.")
						socket:Send(ezPacket, true)
					else
						local ezPacket = easyPacket(400, extra)
						socket:Send(ezPacket, true)
					end
					socket:Disconnect()
					return
				end
			end)

			if (not didError) then
				ErrorNoHalt(details .. "\n")

				local json = util.TableToJSON({["success"]=false, ["message"]="An error occured while processing your request."})
				local returnPacket = BromPacket()
				returnPacket:WriteLine("HTTP/1.1 500 Internal Server Error")
				returnPacket:WriteLine("Server: Conspiracy Servers")
				returnPacket:WriteLine("Content-Type: application/json")
				returnPacket:WriteLine("Content-Length: " .. string.len(json))
				returnPacket:WriteLine("")
				returnPacket:WriteLine(json)
				socket:Send(returnPacket, true)

				socket:Disconnect()
			end
		end)
		
		client:SetTimeout(1000)
		client:ReceiveUntil("\r\n\r")
		
		server:Accept()
	end)
	
	server:Accept()

	return server
end