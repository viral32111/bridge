#define BRIDGE_RECEIVE_SIZE 1024 // 1 KiB

void bridge_setup( const char *clientIdentifier, char *(*receiveCallback)(char*, char*) );

char *bridge_send( const char *destinationClient, char *messageText );
