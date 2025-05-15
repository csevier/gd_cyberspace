This is a functional Godot based metaverse system complete with client and server written in gdscript. It allows you to link seperate scenes via link nodes. You place a link node in your scene and configure it to a url where another metaverse node is hosted.

This allows 3d scenes hosted on serperate servers to be traversed spatially like the real world. For example, one scene may be a house where the door links to a forrest scene on a completely different server. When the user walks through the door they are seemlessly transported to the forrest on a completely different server.

The server hosing system will host a metavese scene with a single commandline flags and other server can link to it easily with link nodes.

It also comes with a caching system, all adjacent world nodes are downloaded asynchronously and only re-downloaded when traversing worlds if the server updates the hash for the scene!
