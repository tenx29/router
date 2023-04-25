# CsrpMessageBuilder

A utility class for creating valid CsrpMessage objects.

## Constructors

### [CsrpMessageBuilder](csrpmessagebuilder.md) new

```lua
CsrpMessageBuilder.new = function()
```

Returns a new [CsrpMessageBuilder](csrpmessagebuilder.md) object.

---

## Properties

### [string](https://create.roblox.com/docs/scripting/luau/strings) Sender

The message sender's JobId. Defaults to the current server's JobId.

### [{string}](https://create.roblox.com/docs/scripting/luau/tables) Recipients

A table of the message recipients' JobIds. Defaults to an empty table.

### [string](https://create.roblox.com/docs/scripting/luau/strings) InteractionId

The message interaction ID. A random GUID will be generated when calling the constructor.

### [{[string]: any}](https://create.roblox.com/docs/scripting/luau/tables#dictionaries) Options

A table of additional message options. Defaults to an empty table.

### [string?](https://create.roblox.com/docs/scripting/luau/strings) Body

The message body. Defaults to `nil`.

---

## Methods

### [CsrpMessageBuilder](csrpmessagebuilder.md) SetSender

```lua
CsrpMessageBuilder:SetSender(sender: string): CsrpMessageBuilder
```

Sets the message sender's JobId. Throws an error if the sender contains semicolons. Returns the [CsrpMessageBuilder](csrpmessagebuilder.md) object for chaining.

### [CsrpMessageBuilder](csrpmessagebuilder.md) SetRecipients

```lua
CsrpMessageBuilder:SetRecipients(recipients: {string}): CsrpMessageBuilder
```

Sets the message recipients' JobIds. Throws an error if any of the recipients contain semicolons. Returns the [CsrpMessageBuilder](csrpmessagebuilder.md) object for chaining.

### [CsrpMessageBuilder](csrpmessagebuilder.md) AddRecipient

```lua
CsrpMessageBuilder:AddRecipient(recipient: string, excludeCurrentForBroadcast: boolean?): CsrpMessageBuilder
```

Adds a recipient to the message. Throws an error if the recipient contains semicolons. Returns the [CsrpMessageBuilder](csrpmessagebuilder.md) object for chaining.

If `recipient` is an empty string, the message will be broadcast to all servers. If `excludeCurrentForBroadcast` is `true` (default), the current server's JobId will be excluded from the broadcast. Setting `excludeCurrentForBroadcast` to `false` will cause the message to be broadcast to all servers, including the current server.

!!! warning
    If `excludeCurrentForBroadcast` is set to `false` when broadcasting to all servers, the sender will also receive the message. Keep this in mind in order to avoid infinite loops.

### [CsrpMessageBuilder](csrpmessagebuilder.md) ExcludeRecipient

```lua
CsrpMessageBuilder:ExcludeRecipient(recipient: string): CsrpMessageBuilder
```

Excludes a recipient from the message by adding it to the Recipients list and prefixing the recipient with `-`. Throws an error if the recipient contains semicolons. Returns the [CsrpMessageBuilder](csrpmessagebuilder.md) object for chaining.

### [CsrpMessageBuilder](csrpmessagebuilder.md) SetInteractionId

```lua
CsrpMessageBuilder:SetInteractionId(interactionId: string): CsrpMessageBuilder
```

Sets the message interaction ID. Throws an error if the interaction ID contains semicolons. Returns the [CsrpMessageBuilder](csrpmessagebuilder.md) object for chaining.

### [CsrpMessageBuilder](csrpmessagebuilder.md) SetOption

```lua
CsrpMessageBuilder:SetOption(option: string, value: any): CsrpMessageBuilder
```

Sets an option on the message. Throws an error if the key or value contain semicolons, commas or equals signs. Returns the [CsrpMessageBuilder](csrpmessagebuilder.md) object for chaining.

### [CsrpMessageBuilder](csrpmessagebuilder.md) SetBody

```lua
CsrpMessageBuilder:SetBody(body: string): CsrpMessageBuilder
```

Sets the message body. Returns the [CsrpMessageBuilder](csrpmessagebuilder.md) object for chaining.

!!! note
    The message body can contain any characters, including semicolons, commas and equals signs.

### [CsrpMessage](csrpmessage.md) Build

```lua
CsrpMessageBuilder:Build(): CsrpMessage
```

Builds the message. Returns the [CsrpMessage](csrpmessage.md) object.
