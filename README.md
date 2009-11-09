Exploring the basics of [Riak](http://riak.basho.com)
==============================

The Rakefile contains a few tasks for simple Riak node management.

Getting Riak:
    
    rake riak:clone


Compiling Riak:

    rake riak:compile


Setting up a node:

    rake riak:new[node1@127.0.0.1,8098]


Starting a node:

	rake riak:start[node1@127.0.0.1]


Stopping a node:

	rake riak:stop[node1@127.0.0.1]


Setting up a second node:

	rake riak:new[node2@127.0.0.1,8099]


Starting both nodes:

	rake riak:start[node1@127.0.0.1]
	rake riak:start[node2@127.0.0.1]


Joining node2 to node1 to form a cluster:

	rake riak:join[node2@127.0.0.1,node1@127.0.0.1]


Stopping node2:

	rake riak:stop[node2@127.0.0.1]


Starting node2:

	rake riak:start[node2@127.0.0.1]


Restoring ringstate for node2 (rejoins cluster):

	rake riak:rejoin[node2@127.0.0.1]