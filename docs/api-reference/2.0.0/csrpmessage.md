# CsrpMessage

A CsrpMessage object represents a message that uses the CSRP specification.

## Constructors

### [CsrpMessage](csrpmessage.md) new

```lua
CsrpMessage.new = function(sender: string?, recipients: {string} | string?, interactionId: string, options: {[string]: any} | string?, body: string?): CsrpMessage
```

Returns a [`CsrpMessage`](csrpmessage.md). Throws an error if an argument is invalid.

Arguments:

1. [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `sender` - The message sender's JobId.
2. [`{string}`](https://create.roblox.com/docs/scripting/luau/tables) or [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `recipients` - The message recipients' JobIds.
3. [`string`](https://create.roblox.com/docs/scripting/luau/strings) `interactionId` - The message interaction ID. Required for fragmented messages.
4. [`{[string]: any}`](https://create.roblox.com/docs/scripting/luau/tables#dictionaries) or [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `options` - The message options.
5. [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `body` - The message body.

!!! note
    The first 4 arguments that form the message header must not contain semicolons (`;`). Additionally, the options argument must not contain equals signs (`=`) or commas (`,`). The message body can contain any characters.

!!! warning "Breaking change from 1.0.0"
    The `fragment` and `fragmentCount` arguments have been removed in release 2.0.0. Fragmentation is now handled using the [`CsrpMessageFragment`](csrpmessagefragment.md) class using the CSRPv2 specification.

### [CsrpMessage](csrpmessage.md) fromString

```lua
CsrpMessage.fromString = function(message: string): CsrpMessage
```

Parse a string into a [`CsrpMessage`](csrpmessage.md). Throws an error if the string is not a valid CSRP message.

Arguments:

1. [`string`](https://create.roblox.com/docs/scripting/luau/strings) `message` - The message string.

---

## Properties

### [string?](https://create.roblox.com/docs/scripting/luau/strings) Sender

The message sender's JobId. Can be nil.

### [string?](https://create.roblox.com/docs/scripting/luau/strings) Recipients

A comma-separated list of the message recipients' JobIds. Can be nil. An empty string indicates that the message is broadcasted to all servers. Prefixing a recipient with a `-` indicates that the recipient should not process the message.

### [string](https://create.roblox.com/docs/scripting/luau/strings) InteractionId

The message interaction ID. Used to identify fragments of the same message. Can also be used to identify request-response pairs.

!!! warning "Breaking change from 1.0.0"
    The `fragment` and `fragmentCount` properties have been removed in release 2.0.0. Fragmentation is now handled using the [`CsrpMessageFragment`](csrpmessagefragment.md) class using the CSRPv2 specification.

### [string?](https://create.roblox.com/docs/scripting/luau/strings) Options

A comma-separated list of the message options. Can be nil. Each option is in the format `key=value`. Not used by Router, but can be used by the user to store additional information about the message.

### [string?](https://create.roblox.com/docs/scripting/luau/strings) Body

The message body. Can be nil and can contain any characters.

---

## Serialization

A CsrpMessage object can be serialized into a string using the built-in `tostring` function.

```lua
local message = CsrpMessage.new("sender", "recipient", "interactionId", "option1=value1,option2=value2", "body")
print(tostring(message)) -- interactionId;sender;recipient;option1=value1,option2=value2;body
```

!!! warning "Breaking change from 1.0.0"
    The serialization order of some properties has changed since release 1.0.0 due to the upgrade to CSRPv2.
