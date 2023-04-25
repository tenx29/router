# Fragmenter

Utility module for splitting messages into smaller chunks and reassembling fragmented messages. Splits messages into chunks no larger than 1000 characters.

## Functions

### [{CsrpMessage}](csrpmessage.md) FragmentMessage

```lua
Fragmenter.FragmentMessage = function(message: CsrpMessage): {CsrpMessage}
```

Splits a message into smaller chunks. Returns a table of messages with a length no greater than 1000 characters. Automatically sets the fragment headers on the messages.

Arguments:

1. [`CsrpMessage`](csrpmessage.md) `message` - The message to fragment.

### [CsrpMessage] DefragmentMessages

```lua
Fragmenter.DefragmentMessages = function(messages: {CsrpMessage}): CsrpMessage
```

Reassembles a table of fragmented messages into a single message. Automatically removes the fragment headers from the messages and sorts the fragments by their index.
