<?php

/* Custom response codes:
	0: Success
	1: API version does not exist
	2: Failed to write data from file
	3: Authentication key is invalid
	4: The HTTP method used for this endpoint is invalid
	5: JSON data for POST request is invalid
	6: Failed to read data from file (the data was probaby never set!)
	7: Failed to JSON decode the data stored in the file
*/

// Set this script's timezone to UTC
date_default_timezone_set( 'UTC' );

// Response content-type will be JSON
header( 'Content-Type: application/json' );

// Disable the client caching responses
header( 'Cache-Control: no-store' );

// Request received unix timestamp with microsecond precision
header( 'Request-Received: ' . $_SERVER[ 'REQUEST_TIME_FLOAT' ] );

// The authentication key
$authenticationKey = 'wE7N7JGQW6N3jxZh3enPkFY5WEETzWpCcGuzVbavWKjH2pVV';

// Fetch endpoint environment variables
$restVersion = $_GET[ 'version' ];
$restInterface = $_GET[ 'interface' ];
$restMethod = $_SERVER[ 'REQUEST_METHOD' ];

// Placeholder for the final response
$finalResponse = [
	'code' => 0
];

// Array to be filled with request headers
$requestHeaders = [];

// Loop through every request header
foreach ( apache_request_headers() as $key => $value ) {

	// Add it to the array with lowercase key name
	$requestHeaders[ strtolower( $key ) ] = $value;

}

// Helper function to give a response
function respond( $code ) {

	// Include variables into function scope
	global $finalResponse;

	// Set the HTTP response code
	http_response_code( $code );

	// Request finished unix timestamp with microsecond precision
	header( 'Request-Finished: ' . microtime( true ) );

	// Output the JSON final response
	echo( json_encode( $finalResponse ) . "\n" );

	// Exit the script
	exit();

}

// Are they not authorized to use this?
if ( preg_match( '/^Key ' . $authenticationKey . '$/', $requestHeaders[ 'authorization' ] ?? '' ) !== 1 ) {

	// Set the response code
	$finalResponse[ 'code' ] = 3;

	// Respond with unauthorized
	respond( 401 );

}

// Decode the request body
$requestData = json_decode( file_get_contents( 'php://input' ), TRUE );

// Is the request data valid JSON for set requests?
if ( $restMethod === 'POST' && ( $_SERVER[ 'CONTENT_TYPE' ] !== 'application/json' || $requestData === NULL ) ) {

	// Set the response code
	$finalResponse[ 'code' ] = 5;

	// Respond with bad request
	respond( 400 );

}

// File name the data file
$dataFilePath = '/tmp/conspiracy-servers-api/v' . $restVersion . '/' . $restInterface . '.cache';

// Do the temporary directories not exist?
if ( is_dir( '/tmp/conspiracy-servers-api/v' . $restVersion ) === FALSE ) {

	// Create temporary directories
	mkdir( '/tmp/conspiracy-servers-api' );
	mkdir( '/tmp/conspiracy-servers-api/v' . $restVersion );

}

// Is this version 1 of the API?
if ( $restVersion === '1' ) {

	// Is this a get request?
	if ( $restMethod === 'GET' ) {

		// Fetch the latest set data
		$data = file_get_contents( $dataFilePath );

		// Did it fail to fetch the data?
		if ( $data === FALSE ) {

			// Set the response code
			$finalResponse[ 'code' ] = 6;

			// Respond with internal server error
			respond( 500 );

		}

		// JSON decode the data
		$decoded = json_decode( $data );

		// Did it fail to decode the data?
		if ( $data === NULL ) {

			// Set the response code
			$finalResponse[ 'code' ] = 7;

			// Respond with internal server error
			respond( 500 );

		}

		// Set the response data
		$finalResponse[ 'data' ] = $decoded;

		// Set the last modified header to the request data's timestamp
		header( 'Last-Modified: ' . filemtime( $dataFilePath ) );

	// Is this a set request?
	} elseif ( $restMethod === 'POST' ) {

		// Set the last modified header to the old data's timestamp
		header( 'Last-Modified: ' . filemtime( $dataFilePath ) );

		// Store the request data in memory
		$result = file_put_contents( $dataFilePath, json_encode( $requestData ) );

		// Did it fail to write the data?
		if ( $result === FALSE ) {

			// Set the response code
			$finalResponse[ 'code' ] = 2;

			// Respond with internal server error
			respond( 500 );

		}

		// Set the response data
		$finalResponse[ 'data' ] = $requestData;

		// Respond with created
		respond( 201 );

	// Invalid request type
	} else {

		// Set the response code
		$finalResponse[ 'code' ] = 4;

		// Respond with method not allowed
		respond( 405 );

	}

// This is an unknown version of the API
} else {

	// Set the response code
	$finalResponse[ 'code' ] = 1;

	// Set the status code to not found
	respond( 404 );

}

// Respond with success
respond( 200 );

?>