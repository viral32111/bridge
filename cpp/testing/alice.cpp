// Import standard libraries
#include <stdio.h>
#include <string.h>

// Import the bridge library
#include "bridge.h"

// Define the message receive callback
char *receive( char *message, char *sender ) {
	printf( "Received '%s' from '%s'.\n", message, sender );
	char *response = strdup( "hi" );
	return response;
}

// The program's entry point
int main() {

	// Name this bridge client and associate the callback
	bridge_setup( "alice", &receive );

	// Create a buffer to hold user input
	char userInput[ BRIDGE_RECEIVE_SIZE ] = { 0 };

	// Loop forever
	while ( 1 ) {

		// Reset user input
		memset( userInput, 0, sizeof( userInput ) );

		// Take input from the command line
		scanf( "%s", userInput );

		// Send it to the other and store their response
		char *response = bridge_send( "mary", userInput );

		// Print their response
		printf( "They responded with '%s'.\n", response );

	}

	// Successful exit
	return 0;

}
