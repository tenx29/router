# FragmentBuffer

The `FragmentBuffer` class stores the fragments of a message for reassembly. It is used by the [StreamConnection](streamconnection.md) class.

## Constructors

### [FragmentBuffer](fragmentbuffer.md) new

```lua
FragmentBuffer.new = function(timeout: number?): FragmentBuffer
```

Returns a new [FragmentBuffer](fragmentbuffer.md) object with the given timeout. If `timeout` is not provided, 10 seconds will be used.

Arguments:

1. [`number?`](https://create.roblox.com/docs/scripting/luau/numbers) `timeout` - The timeout in seconds.

---

## Properties

### [number](https://create.roblox.com/docs/scripting/luau/numbers) Timeout

The buffer timeout in seconds. If a new fragment is not received within this time, the buffer will be cleared to prevent memory leaks.

### [number](https://create.roblox.com/docs/scripting/luau/numbers) CutOffTime

The time at which the buffer will be cleared if no new fragments are received.

### [number](https://create.roblox.com/docs/scripting/luau/numbers) TotalFragments

The number of fragments the full message is expected to have.

### [{CsrpMessage}](https://create.roblox.com/docs/scripting/luau/tables) Fragments

The received fragments of the message. The key is the fragment index and the value is the message fragment object.

---

## Events

### [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal) TimedOut

Fired when the buffer times out.

---

## Methods

### [void](fragmentbuffer.md#void-add) Add

```lua
FragmentBuffer:Add = function(fragment: CsrpMessage)
```

Adds a fragment to the buffer and resets the timeout timer.

Arguments:

1. [`CsrpMessage`](csrpmessage.md) `fragment` - The fragment to add.

### [boolean](https://create.roblox.com/docs/scripting/luau/booleans) IsComplete

```lua
FragmentBuffer:IsComplete = function(): boolean
```

Returns whether the buffer contains all of the fragments of the message.

### [void](fragmentbuffer.md#void-disable) Disable

```lua
FragmentBuffer:Disable = function()
```

Disables the buffer. This will prevent additional fragments from being added to the buffer and will stop the timeout timer.

### [void](fragmentbuffer.md#void-dispose) Dispose

```lua
FragmentBuffer:Dispose = function()
```

Disables and clears the buffer.
