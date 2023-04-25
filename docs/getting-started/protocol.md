# Cross-Server Routing Protocol

The Router library uses a custom Cross-Server Routing Protocol (CSRP) to communicate between servers. The full CSRP specification can be found at [tenx29/roblox-csrp](https://www.github.com/tenx29/roblox-csrp).

The CSRP is designed to be a simple and easy to implement protocol that can be used to communicate between servers using Roblox's built-in MessagingService. Understanding the protocol is not required to use Router as the protocol-specific aspects are abstracted away by the library. However, the CSRP places some restrictions on message headers that may be useful to know about.

!!! important
    Router has been upgraded to use [CSRPv2](https://www.github.com/tenx29/roblox-csrp/tree/main/v2) in release 2.0.0. This version of the protocol is not backwards compatible with CSRPv1. If you are using Router 1.0.0, you should upgrade to 2.0.0 or later.

## Routing

While Roblox's MessagingService does not allow sending messages to a specific server, Router implements a system that ignores messages that are not intended for the current server.

## Routing Examples

Below is a table containing some examples of how the CSRP routes messages between servers.

| Recipient string      | Description |
| --------------------- | ----------- |
| `""`                  | The message is intended for all servers, including the current server.
| `"-"`                 | The message isn't intended for any servers.
| `"aaa111"`            | The message is intended for the server with the job ID `aaa111`.
| `"aaa111,bbb222"`     | The message is intended for the servers with the job IDs `aaa111` and `bbb222`.
| `",-bbb222"`          | The message is intended for all servers except the server with the job ID `bbb222`.
| `",-bbb222,-ccc333"`  | The message is intended for all servers except the servers with the job IDs `bbb222` and `ccc333`.
| `aaa111,-aaa111"`     | The message is intended for `aaa111`, but not `aaa111` (i.e. no servers).
