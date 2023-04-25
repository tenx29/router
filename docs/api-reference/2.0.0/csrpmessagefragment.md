# CsrpMessageFragment

A CsrpMessageFragment object represents a fragment of a message that uses the CSRPv2 specification.

## Constructors

### [CsrpMessageFragment](csrpmessagefragment.md) new

```lua
CsrpMessageFragment.new = function(interactionId: string?, fragment: number?, fragmentCount: number?, content: string?): CsrpMessageFragment
```

Returns a [`CsrpMessageFragment`](csrpmessagefragment.md).

Arguments:

1. [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `interactionId` - The message interaction ID. Required when there are multiple fragments.
2. [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) `fragment` - The fragment number.
3. [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) `fragmentCount` - The total number of fragments.
4. [`string?`](https://create.roblox.com/docs/scripting/luau/strings) `content` - The encapsulated message fragment content.

!!! note
    The first 3 arguments that form the message header must not contain semicolons (`;`). The message content can contain any characters.

### [CsrpMessageFragment](csrpmessagefragment.md) fromString

```lua
CsrpMessageFragment.fromString = function(message: string): CsrpMessageFragment
```

Parse a string into a [`CsrpMessageFragment`](csrpmessagefragment.md). Throws an error if the string is not a valid CSRPv2 message fragment.

Arguments:

1. [`string`](https://create.roblox.com/docs/scripting/luau/strings) `message` - The message to parse.

---

## Properties

### [`string?`](https://create.roblox.com/docs/scripting/luau/strings) InteractionId

The message interaction ID. Required when there are multiple fragments.

### [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) Fragment

The fragment sequence number. Starts at 1.

### [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) FragmentCount

The total number of fragments in the message.

### [`string?`](https://create.roblox.com/docs/scripting/luau/strings) Content

The encapsulated message fragment content. Can contain any characters.

---

## Serialization

A CsrpMessageFragment object can be serialized into a string using the built-in `tostring` function.

```lua
local fragment = CsrpMessageFragment.new("interactionId", 1, 2, "content")
print(tostring(fragment)) --> "interactionId;1;2;content"
```
