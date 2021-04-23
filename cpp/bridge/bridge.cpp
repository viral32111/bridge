// https://github.com/troydhanson/network/blob/master/unixdomain/01.basic/srv.c
// https://github.com/troydhanson/network/blob/master/unixdomain/01.basic/cli.c
// g++ -Wall peertopeer.cpp -o /tmp/peertopeer && /tmp/peertopeer

#include <stdio.h>
//#include <stdlib.h>
//#include <unistd.h>
//#include <sys/socket.h>
//#include <sys/un.h>

/*void _receiveData() {
	
}*/

void bridge_setup( const char clientIdentifier, char *receiveCallback ) {
	printf( "bridge_setup" );
}

char *bridge_send( const char destinationClient, char *messageText ) {
	printf( "bridge_send" );
	char *response = strdup( "placeholder" );
	return response;
}

/*
int main() {
	char serverSocketPath[] = "/tmp/server_socket";
	struct sockaddr_un unixDomainSocketAddress;

	int serverSocket = socket( AF_UNIX, SOCK_STREAM, 0 );
	if ( serverSocket == -1 ) {
		printf( "Error occured creating the socket!\n" );
		exit( -1 );
	}

	memset( &unixDomainSocketAddress, 0, sizeof( unixDomainSocketAddress ) );
	unixDomainSocketAddress.sun_family = AF_UNIX;
	strncpy( unixDomainSocketAddress.sun_path, serverSocketPath, sizeof( unixDomainSocketAddress.sun_path ) - 1 );
	unlink( serverSocketPath );

	int bindResult = bind( serverSocket, ( struct sockaddr* ) &unixDomainSocketAddress, sizeof( unixDomainSocketAddress ) );
	if ( bindResult == -1 ) {
		printf( "Error occured binding the socket!\n" );
		exit( -1 );
	}

	int listenResult = listen( serverSocket, 5 );
	if ( listenResult == -1 ) {
		printf( "Error occured listening the socket!\n" );
		exit( -1 );
	}

	while ( true ) {
		int clientSocket = accept( serverSocket, NULL, NULL );
		if ( clientSocket == -1 ) {
			printf( "Error occured accepting the client socket!\n" );
			exit( -1 );
		}

		ssize_t numberOfBytesRead = 0;
		char receivedDataBuffer[ 100 ] = { 0 };
		while ( ( numberOfBytesRead = read( clientSocket, receivedDataBuffer, sizeof( receivedDataBuffer ) ) ) > 0 ) {
			printf( "Received %lu bytes: '%s'.\n", numberOfBytesRead, receivedDataBuffer );
			memset( receivedDataBuffer, 0, sizeof( receivedDataBuffer ) );
		}

		if ( numberOfBytesRead == -1 ) {
			printf( "Error occured reading client socket data!\n" );
			exit( -1 );
		} else if ( numberOfBytesRead == 0 ) {
			printf( "End of file!\n" );
			close( clientSocket );
		}
	}

	return 0;
}
*/
