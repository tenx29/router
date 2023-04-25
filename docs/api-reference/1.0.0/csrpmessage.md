# CsrpMessage

A CsrpMessage object represents a message that uses the CSRP specification.

## Constructors

### [CsrpMessage](csrpmessage.md) new

```lua
CsrpMessage.new = function(sender: string?, recipients: {string} | string?, interactionId: string, fragment: number?, fragmentCount: number?, options: {[string]: any} | string?, body: string?): CsrpMessage
```

Returns a [`CsrpMessage`](csrpmessage.md). Throws an error if an argument is invalid.

Arguments:

1. [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `sender` - The message sender's JobId.
2. [`{string}`](https://create.roblox.com/docs/scripting/luau/tables) or [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `recipients` - The message recipients' JobIds.
3. [`string`](https://create.roblox.com/docs/scripting/luau/strings) `interactionId` - The message interaction ID. Required for fragmented messages.
4. [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) `fragment` - The message fragment number.
5. [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) `fragmentCount` - The message fragment count. If nil, will be interpreted as 1.
6. [`{[string]: any}`](https://create.roblox.com/docs/scripting/luau/tables#dictionaries) or [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `options` - The message options.
7. [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `body` - The message body.

!!! note
    The first 6 arguments that form the message header must not contain semicolons (`;`). Additionally, the options argument must not contain equals signs (`=`) or commas (`,`). The message body can contain any characters.

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

### [number?](https://create.roblox.com/docs/scripting/luau/numbers) Fragment

The message fragment number. If nil, it will be interpreted as equal to FragmentCount if FragmentCount is not nil, otherwise 1.

### [number?](https://create.roblox.com/docs/scripting/luau/numbers) FragmentCount

The total number of fragments in the message. If nil, it will be interpreted as 1.

### [string?](https://create.roblox.com/docs/scripting/luau/strings) Options

A comma-separated list of the message options. Can be nil. Each option is in the format `key=value`. Not used by Router, but can be used by the user to store additional information about the message.

### [string?](https://create.roblox.com/docs/scripting/luau/strings) Body

The message body. Can be nil and can contain any characters.

---

## Serialization

A CsrpMessage object can be serialized into a string using the built-in `tostring` function.

```lua
local message = CsrpMessage.new("sender", "recipient", "interactionId", 1, 2, "option1=value1,option2=value2", "body")
print(tostring(message)) -- sender;recipient;interactionId;1;2;option1=value1,option2=value2;body
```
