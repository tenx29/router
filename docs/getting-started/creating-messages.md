# Creating Messages

In Router, messaging happens using CsrpMessage objects. The library also provides a CsrpMessageBuilder class to help with creating messages. A CsrpMessage can be created as follows:

```lua
-- We'll assume that Router is already defined here and in future snippets
local CsrpMessageBuilder = require(Router.CsrpMessageBuilder)
local message = CsrpMessageBuilder.new()
    :AddRecipient("ae63c7e0-1b1e-4b1e-9c1e-1b1e4b1e9c1e")
    :setBody("Hello, world!")
    :Build()
```

The above snippet creates a message with a single recipient and a body of "Hello, world!". The CsrpMessage object is then stored in the `message` variable. Once sent, the message will be received by the server with the [JobId](https://create.roblox.com/docs/reference/engine/classes/DataModel#JobId) `ae63c7e0-1b1e-4b1e-9c1e-1b1e4b1e9c1e`.

!!! note
    Using the CsrpMessageBuilder class is recommended as it validates message headers as they are added. However, it is possible to create a CsrpMessage object directly by using the CsrpMessage constructor.

---
