// https://github.com/troydhanson/network/blob/master/unixdomain/01.basic/cli.c
// g++ -Wall client.cpp -o /tmp/client && /tmp/client

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

int main() {
	char socketPath[] = "/tmp/socket";
	struct sockaddr_un unixDomainSocketAddress;

	int clientSocket = socket( AF_UNIX, SOCK_STREAM, 0 );
	if ( clientSocket == -1 ) {
		printf( "Error occured creating the socket!\n" );
		exit( -1 );
	}

	memset( &unixDomainSocketAddress, 0, sizeof( unixDomainSocketAddress ) );
	unixDomainSocketAddress.sun_family = AF_UNIX;
	strncpy( unixDomainSocketAddress.sun_path, socketPath, sizeof( unixDomainSocketAddress.sun_path ) - 1 );

	int connectResult = connect( clientSocket, ( struct sockaddr* ) &unixDomainSocketAddress, sizeof( unixDomainSocketAddress ) );
	if ( connectResult == -1 ) {
		printf( "Error occured connecting to the socket!\n" );
		exit( -1 );
	}

	ssize_t numberOfBytesRead = 0;
	char userInputBuffer[ 100 ];

	while ( ( numberOfBytesRead = read( STDIN_FILENO, userInputBuffer, sizeof( userInputBuffer ) ) ) > 0 ) {
		if ( write( clientSocket, userInputBuffer, numberOfBytesRead ) != numberOfBytesRead ) {
			if ( numberOfBytesRead > 0 ) {
				printf( "Partial write!\n" );
			} else {
				printf( "Error occured while writing!\n" );
				exit( -1 );
			}
		}
	}

	return 0;
}
