# Fragmenter

Utility module for splitting messages into smaller chunks and reassembling fragmented messages. Splits messages into chunks no larger than 1000 bytes.

## Functions

### [{CsrpMessageFragment}](csrpmessagefragment.md) FragmentMessage

```lua
Fragmenter.FragmentMessage = function(message: CsrpMessage, maxLength: number?): {CsrpMessageFragment}
```

Splits a message into smaller chunks. Returns a table of messages with a length no greater `maxLength`, or 1000 bytes if `maxLength` is nil. Automatically sets the fragment headers on the messages.

Arguments:

1. [`CsrpMessage`](csrpmessage.md) `message` - The message to fragment.
2. [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) `maxLength` - The maximum length of each fragment. Defaults to 1000.

!!! warning "Breaking change from 1.0.0"
    The return type of this function was changed from [`{CsrpMessage}`](csrpmessage.md) to [`{CsrpMessageFragment}`](csrpmessagefragment.md) in 2.0.0.

### [CsrpMessage](csrpmessage.md) DefragmentMessages

```lua
Fragmenter.DefragmentMessages = function(messages: {CsrpMessageFragment}): CsrpMessage
```

Reassembles a table of fragmented messages into a single message. Automatically removes the fragment headers from the messages and sorts the fragments by their index.

Arguments:

1. [`{CsrpMessageFragment}`](csrpmessagefragment.md) `messages` - The messages to defragment.

!!! warning "Breaking change from 1.0.0"
    The `messages` argument type was changed from [`{CsrpMessage}`](csrpmessage.md) to [`{CsrpMessageFragment}`](csrpmessagefragment.md) in 2.0.0.
