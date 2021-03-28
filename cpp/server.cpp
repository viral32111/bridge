// https://github.com/troydhanson/network/blob/master/unixdomain/01.basic/srv.c
// g++ -Wall server.cpp -o /tmp/server && /tmp/server

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

int main() {
	char socketPath[] = "/tmp/socket";
	struct sockaddr_un unixDomainSocketAddress;

	int serverSocket = socket( AF_UNIX, SOCK_STREAM, 0 );
	if ( serverSocket == -1 ) {
		printf( "Error occured creating the socket!\n" );
		exit( -1 );
	}

	memset( &unixDomainSocketAddress, 0, sizeof( unixDomainSocketAddress ) );
	unixDomainSocketAddress.sun_family = AF_UNIX;
	strncpy( unixDomainSocketAddress.sun_path, socketPath, sizeof( unixDomainSocketAddress.sun_path ) - 1 );
	unlink( socketPath );

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
