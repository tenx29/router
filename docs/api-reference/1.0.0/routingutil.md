# RoutingUtil

Utility module for checking if a message is intended for the current server.

## Functions

### [boolean](https://create.roblox.com/docs/scripting/luau/types#boolean) IsCurrentServerSender

```lua
RoutingUtil.IsCurrentServerSender = function(message: CsrpMessage | string): boolean
```

Returns whether the message sender is the current server. If the message is a string, it will be parsed as a [CsrpMessage](csrpmessage.md).

Arguments:

1. [`CsrpMessage`](csrpmessage.md) or [`string`](https://create.roblox.com/docs/scripting/luau/strings) `message` - The message to check.

### [boolean](https://create.roblox.com/docs/scripting/luau/types#boolean) IsCurrentServerRecipient

```lua
RoutingUtil.IsCurrentServerRecipient = function(message: CsrpMessage | string): boolean
```

Returns whether the message is intended for the current server. If the message is a string, it will be parsed as a [CsrpMessage](csrpmessage.md).

Arguments:

1. [`CsrpMessage`](csrpmessage.md) or [`string`](https://create.roblox.com/docs/scripting/luau/strings) `message` - The message to check.
