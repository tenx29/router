# StreamConnection

The `StreamConnection` class stores a single connection to a MessageStream along with the buffers used to store the fragments of a message. It is returned by the [MessageStream:Subscribe](messagestream.md#streamconnection-subscribe) method.

## Constructors

### [StreamConnection](streamconnection.md) new

```lua
StreamConnection.new = function(connection: RBXScriptConnection, buffers: {[string]: FragmentBuffer}): StreamConnection
```

Returns a new [StreamConnection](streamconnection.md) object with the given connection and buffers.

Arguments:

1. [`RBXScriptConnection`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) `connection` - The connection to the MessageStream.
2. [`{[string]: FragmentBuffer}`](https://create.roblox.com/docs/scripting/luau/tables#dictionaries) `buffers` - The buffers used to store the fragments of a message.

---

## Properties

### [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) Connection

The connection to the MessagingService topic.

### [boolean](https://create.roblox.com/docs/scripting/luau/booleans) Connected

Whether the connection is still active.

### [{[string]: FragmentBuffer}](https://create.roblox.com/docs/scripting/luau/tables#dictionaries) Buffers

The buffers used to store the fragments of a message. A message with a given interaction ID will be stored in the buffer with the same key. A buffer is cleared when the last fragment of a message is received.

---

## Methods

### [void](streamconnection.md#void-disconnect) Disconnect

```lua
StreamConnection:Disconnect = function()
```

Disconnects the connection to the MessagingService topic and disposes of the buffers.
