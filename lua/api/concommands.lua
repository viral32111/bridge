concommand.Add("apiserver_start", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	print("Started API server.")

	if (#args == 0) then
		api.server = api.startServer(27108)
	else
		local port = tonumber(args[1])
		api.server = api.startServer(port)
	end
end, nil, "Starts the API server.", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("apiserver_stop", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	if (api.server) then
		print("Stopped API server.")
		api.server:Close()
		api.server = nil
	else
		print("API server not running.")
	end
end, nil, "Stops the API server.", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("apiserver_status", function(ply, cmd, args)
	if (IsValid(ply)) then return end -- Console only

	print(api.server)
end, nil, "Dumps the status of the API server.", FCVAR_SERVER_CAN_EXECUTE)