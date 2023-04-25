# MessageStream

The `MessageStream` class is a wrapper for MessagingService that handles routing and fragmentation according to the [CSRP](../../getting-started/protocol.md) specification. A MessageStream object represents a single MessagingService topic.

## Constructors

### [MessageStream](messagestream.md) new

```lua
MessageStream.new = function(topic: string?, bufferTimeout: number?): MessageStream
```

Returns a new [MessageStream](messagestream.md) object. If `topic` is not provided, `"CSRP_GLOBAL"` will be used. If `bufferTimeout` is not provided, 10 seconds will be used.

Arguments:

1. [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `topic` - The MessagingService topic to use.
2. [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) `bufferTimeout` - Timeout in seconds for fragment buffers.

!!! danger
    Do not use a MessageStream or a MessagingService topic used by a MessageStream for sending or receiving messages that don't conform to the CSRP specification.

---

## Properties

### [string](https://create.roblox.com/docs/scripting/luau/strings) Topic

The MessagingService topic used by the MessageStream.

---

## Methods

### [void](messagestream.md#void-send) Send

```lua
MessageStream:Send = function(message: CsrpMessage)
```

Send a [CsrpMessage](csrpmessage.md) to the MessageStream's topic. Automatically fragments the message if it exceeds the maximum message size. Retries sending the message if it fails up to 10 times with a 1 second delay between each attempt.

Arguments:

1. [`CsrpMessage`](csrpmessage.md) `message` - The message to send.

### [StreamConnection](streamconnection.md) Subscribe

```lua
MessageStream:Subscribe = function(callback: (CsrpMessage, number) -> ()): StreamConnection
```

Subscribe to the MessageStream. The callback will be invoked with the full message when all fragments of a message have been received. The callback will be invoked with two arguments: the [CsrpMessage](csrpmessage.md) object and the time at which the last fragment of the message was received. The callback will only be invoked for messages that are intended for the current server.

Arguments:

1. [`(CsrpMessage, number) -> ()`](https://create.roblox.com/docs/scripting/luau/functions#callbacks) `callback` - The callback to invoke when a message is received.
