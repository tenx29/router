# Sending & Receiving Messages

Router provides a MessageStream class for sending and receiving messages. The MessageStream class automatically handles fragmentation and reassembly of messages as well as message routing. The MessageStream class is used to send and receive messages on a specific MessagingService topic.

!!! danger
    Do not use a MessageStream or a MessagingService topic used by a MessageStream for sending or receiving messages that don't conform to the CSRP specification.

## Sending Messages

Once a message is created, it must be sent to the other servers. There are two ways to send messages: using the Router library (recommended) and using the MessagingService directly.

!!! note
    In these examples, we'll assume a variable named `message` has been created and contains a CsrpMessage object.

### Using Router

To send a message using Router, you must first create a MessageStream object. A MessageStream object is used to send and receive messages on a specific MessagingService topic. The constructor takes a MessagingService topic as its only argument. The following snippet creates a MessageStream object using the default topic:

```lua
local MessageStream = require(Router.MessageStream)
local stream = MessageStream.new()
```

This will create a new MessageStream object that uses the default `CSRP_GLOBAL` topic. Once a MessageStream object is created, it can be used to send messages:

```lua
stream:Send(message)
```

### Using MessagingService

!!! warning
    Using the MessagingService directly is not recommended as it can't fragment messages if they are too large.

Sending messages using the MessagingService is very similar to sending messages using Router. The following snippet sends a CSRP message:

```lua
local MessagingService = game:GetService("MessagingService")
MessagingService:PublishAsync("CSRP_GLOBAL", message)
```

---

## Receiving Messages

To receive messages, you must first create a MessageStream object. A MessageStream object is used to send and receive messages on a specific MessagingService topic. The MessageStream automatically handles reassembly of fragmented messages as well as message routing. When subscribing to a MessageStream, you must provide a callback function that will be called when a message is received. The callback function can take up to two arguments: the CsrpMessage object and the time at which the last fragment of the message was received. The following snippet creates a MessageStream object and subscribes to it:

```lua
local MessageStream = require(Router.MessageStream)
local stream = MessageStream.new()
local connection = stream:Subscribe(function(message, lastFragmentTime)
    -- Handle message
end)
```

The connection will only be invoked for messages that are intended for the current server.
