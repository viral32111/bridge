# Import the bridge library
import bridge

# Define the message receive callback
def receive( message, sender ):
	print( "Received '" + message + "' from '" + sender + "'." )
	return "sup"

# Name this bridge client and associate the callback
bridge.setup( "mary", receive )

# Loop forever
while True:

	# Take input from the command line
	userInput = input()

	# Send it to the other and store their response
	response = bridge.send( "alice", userInput )

	# Print their response
	print( "They responded with '" + response + "'.\n" )
