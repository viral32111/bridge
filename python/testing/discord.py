import socket, os, time, threading

# server setup
if os.path.exists( "/tmp/discord.server.sock" ): os.remove( "/tmp/discord.server.sock" )
server = socket.socket( socket.AF_UNIX, socket.SOCK_DGRAM )
server.bind( "/tmp/discord.server.sock" )

# client setup
if os.path.exists( "/tmp/discord.client.sock" ): os.remove( "/tmp/discord.client.sock" )
client = socket.socket( socket.AF_UNIX, socket.SOCK_DGRAM )
client.bind( "/tmp/discord.client.sock" )

# server listen
def listen():
	while True:
		data, address = server.recvfrom( 1024 )
		server.sendto( "imdiscord".encode(), address )
		print( "received", data.decode(), "from", address )

# client ask
def ask( who, message ):
	client.sendto( message.encode(), "/tmp/" + who + ".server.sock" )
	data, address = client.recvfrom( 1024 )
	return data.decode()

# start server
thread = threading.Thread( target = listen )
thread.start()

# message from client
print( ask( "sandbox", "status" ) )
