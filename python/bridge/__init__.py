# Import native modules
import socket, threading, random, os

# Set configuration
_SOCKETS_PATH = "/tmp/bridge"

# Private variables
_clientIdentifier = None
_serverReceiveCallback = None
_receiveSocket = socket.socket( socket.AF_UNIX, socket.SOCK_DGRAM )
_serverSocketPath = None
_serverShouldCancel = False

# Listen for incoming data on the server socket
def _serverListen():
	while not _serverShouldCancel:
		data, path = server.recvfrom( 1024 )
		# call receive event
		server.sendto( "".encode(), path )

# set listen thread
_serverListenThread = threading.Thread( target = _serverListen )

# Sets up this bridge client
def setup( clientIdentifier, receiveCallback ):
	global _clientIdentifier, _serverReceiveCallback, _serverSocketPath

	_clientIdentifier = clientIdentifier
	_serverReceiveCallback = receiveCallback

	_serverSocketPath = _SOCKETS_PATH + "/" + clientIdentifier + ".sock"
	server.bind( _serverSocketPath )






# client ask
def ask( who, message ):
	client.sendto( message.encode(), "/tmp/" + who + ".server.sock" )
	data, address = client.recvfrom( 1024 )
	return data.decode()

# Remove the server socket file if it exists
if os.path.exists( _serverSocketPath ):
	os.remove( _serverSocketPath )






# start server

thread.start()

# message from client
print( ask( "sandbox", "status" ) )
