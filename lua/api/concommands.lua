concommand.Add("apiserver_start", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	local port = api.server.port
	api.host = api.startHost(port)
end, nil, "Starts the API server.", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("apiserver_stop", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	if (api.host) then
		print("Stopped API server.")
		api.host:Close()
		api.host = nil
	else
		print("API server not running.")
	end
end, nil, "Stops the API server.", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("apiserver_status", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	print(api.host)
	PrintTable(api.clients)
end, nil, "Dumps the status of the API server.", FCVAR_SERVER_CAN_EXECUTE)