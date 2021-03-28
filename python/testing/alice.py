# Import the bridge library
import bridge

# Define the message receive callback
def receive( message, sender ):
	print( "Received '" + message + "' from '" + sender + "'." )
	return "hi"

# Name this bridge client and associate the callback
bridge.setup( "alice", receive )

# Loop forever
while True:

	# Take input from the command line
	userInput = input()

	# Send it to the other and store their response
	response = bridge.send( "mary", userInput )

	# Print their response
	print( "They responded with '" + response + "'.\n" )
