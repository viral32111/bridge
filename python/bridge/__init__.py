# Import native modules
import socket, threading, random, os, re

# Configuration
_SOCKETS_PATH = "/tmp/bridge"
_RECEIVE_SIZE = 1024 # 1KiB

# Private variables
_clientIdentifier = None
_receiveCallback = None
_receiveSocket = None
_receiveSocketPath = None
_receiveDataThread = None
_receiveDataThreadCancel = False

# Receive incoming data
def _receiveData():

	# Include global variables
	global _receiveSocket, _receiveDataThreadCancel, _receiveCallback

	# Loop until the cancel flag is set
	while not _receiveDataThreadCancel:

		# Receiving data from anyone sending it
		receivedData, senderPath = _receiveSocket.recvfrom( _RECEIVE_SIZE )

		# Get just the sender client name from the path
		senderName = re.match( _SOCKETS_PATH + "/(\w+)\.\w+\.sock", senderPath ).group( 1 )

		# Call the message received event with the decoded message and sender name
		eventResponse = _receiveCallback( receivedData.decode(), senderName )

		# Send back the encoded response from the event
		_receiveSocket.sendto( eventResponse.encode(), senderPath )

# Sets up this client
def setup( clientIdentifier, receiveCallback ):

	# Include global variables
	global _clientIdentifier, _receiveCallback, _receiveSocket, _receiveSocketPath, _receiveDataThread

	# Update global variables
	_clientIdentifier = clientIdentifier
	_receiveCallback = receiveCallback
	_receiveSocketPath = _SOCKETS_PATH + "/" + clientIdentifier + ".sock"

	# Create the receiving socket
	_receiveSocket = socket.socket( socket.AF_UNIX, socket.SOCK_DGRAM )

	# Create the sockets path if it does not exist
	os.makedirs( _SOCKETS_PATH, exist_ok = True )

	# Remove the receive socket path if it exists
	if os.path.exists( _receiveSocketPath ): os.remove( _receiveSocketPath )

	# Bind receiving socket to the newly set path
	_receiveSocket.bind( _receiveSocketPath )

	# Create and start the receive data thread
	_receiveDataThread = threading.Thread( target = _receiveData )
	_receiveDataThread.start()

# Sends a message to another client
def send( destinationClient, messageText ):

	# Include global variables
	global _clientIdentifier

	# Create a new temporary socket for sending it
	sendSocket = socket.socket( socket.AF_UNIX, socket.SOCK_DGRAM )

	# Generate a random string to use in the sending socket path
	randomName = "".join( [ random.choice( "abcdefghijklmnopqrstuvwxyz" ) for _ in range( 4 ) ] )

	# Store the sending socket path
	sendSocketPath = _SOCKETS_PATH + "/" + _clientIdentifier + "." + randomName + ".sock"

	# Create the sockets path if it does not exist
	os.makedirs( _SOCKETS_PATH, exist_ok = True )

	# Remove the send socket path if it exists
	if os.path.exists( sendSocketPath ): os.remove( sendSocketPath )

	# Bind to a randomly generated socket path
	sendSocket.bind( sendSocketPath )

	# Encode the message and send it to the destination client
	sendSocket.sendto( messageText.encode(), _SOCKETS_PATH + "/" + destinationClient + ".sock" )

	# Receive their reply
	receivedData, _ = sendSocket.recvfrom( _RECEIVE_SIZE )

	# Delete the temporary socket path
	os.remove( sendSocketPath )

	# Return the decoded received data
	return receivedData.decode()
