# Bridge

This is my internal and backend communication library for my community game servers, and possibly other services in the future.

**This is not designed to be used by anyone other than myself on my own servers, you cannot just download it and expect it to work for you.**

**THIS IS STILL IN DEVELOPMENT AND DOES __NOT__ WORK YET!**

## Details

The communication operates over a [peer-to-peer](https://en.wikipedia.org/wiki/Peer-to-peer) based connection to [unix domain sockets](https://en.wikipedia.org/wiki/Unix_domain_socket) using [datagram](https://en.wikipedia.org/wiki/Datagram) packets, making it strictly local to the host device.

Each bridge client will create a receiving socket. Whenever it wants to communicate to another client, it will create a temporary sending socket, send messages to that client's receiving socket, and then it will get a response back through the temporary sending socket, which is then deleted after the communication.

## Use Cases

Fetching live status information (e.g. hostname, map, players, tickrate) for each game server from Discord, updating a Discord category name or channel topic from each game server, etc.

## History

This library is designed to be much more modular in comparison to my previous very limited & broken API I was using, it relies more on each client implementing features at their end, instead having a central server that controls and checks all features.

The previous API was HTTP based and required each client to create their own TCP HTTP server, listen for connections, respond to each one syncronously and then close the connection. It worked, but was not ideal firstly it required the game server to do much more processing, and secondly because it meant additional ports had to be opened which of course brings security risks along with it. However, I did not have the option to create something new like this because all services were hosted on seperate machines, but now that I own my own dedicated server, I can have everything run on it and communicate locally.

I did attempt to create a second version of the old API that used a central web server running a PHP script to process and deliver requests, but that was a polling based system and would put much more additional strain on the web server.

## Usage

### [Python](python/)

This is a [Python module](https://docs.python.org/3/tutorial/modules.html), below is a concept of how it should be used.

```python
# Import the bridge library
import bridge

# Define the message receive callback
async def receive( message, source ):
	print( "Received " + message + " from " + source )
	return "example"

# Name this bridge client and associate the callback
bridge.setup( "python", receive )

# Send a message to another service and store their response
# This can be called at any time after bridge.setup()
response = await bridge.send( "cpp", "hello" )
```

### [C++](cpp/)

This is a [Garry's Mod binary module](https://wiki.facepunch.com/gmod/Creating_Binary_Modules), below is a concept of how it should be used.

```lua
-- Import the bridge library
require( "bridge" )

-- Define the message receive callback
local function receive( message, source )
	print( "Received " .. message .. " from " .. source )
	return "example"
end

-- Name this bridge client and associate the callback
bridge.setup( "garrysmod", receive )

-- Send a message to another service and store their response
-- This can be called at any time after bridge.setup()
bridge.send( "discord", "hello" )
```

### [Java](java/)

This is a [Minecraft bukkit plugin](https://dev.bukkit.org/).

*I am still learning Java and Minecraft plugin programming, so I have no idea how I would go about doing this yet!*

## License

Copyright (C) 2019 - 2022 [viral32111](https://viral32111.com).

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see https://www.gnu.org/licenses.
