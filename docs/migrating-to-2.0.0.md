# Migrating to 2.0.0

This is a guide for migrating from Router 1.0.0 to 2.0.0. Router 2.0.0 is a major update that introduces breaking changes. The guide lists the breaking changes and provides instructions on how to update your code to use the new version.

## Who should read this guide?

If you're currently using Router 1.0.0 and are directly using one of the following APIs, you should read this guide:

- [`Fragmenter`](api-reference/1.0.0/fragmenter.md)
- [`FragmentBuffer`](api-reference/1.0.0/fragmentbuffer.md)
- [`CsrpMessage`](api-reference/1.0.0/csrpmessage.md)

Additionally, if you are currently directly handling serialized CSRP messages, you should read this guide, as message serialization has changed with CSRPv2.

## Breaking changes

### Protocol upgrade to CSRPv2

The underlying protocol Router uses has been upgraded from CSRPv1 to CSRPv2 which requires less overhead for fragmented messages. The new protocol is not backwards compatible with CSRPv1, so Router 2.0.0 is not compatible with Router 1.0.0.

### Fragmenter changes

The Fragmenter API has been changed due to the CSRPv2 upgrade.

- The [`FragmentMessage`](api-reference/2.0.0/fragmenter.md#csrpmessagefragment-fragmentmessage) function now returns a table of [`CsrpMessageFragment`](api-reference/2.0.0/csrpmessagefragment.md) objects instead of a table of [`CsrpMessage`](api-reference/1.0.0/csrpmessage.md) objects.
- The [`DefragmentMessages`](api-reference/2.0.0/fragmenter.md#csrpmessage-defragmentmessages) function now takes a table of [`CsrpMessageFragment`](api-reference/2.0.0/csrpmessagefragment.md) objects instead of a table of [`CsrpMessage`](api-reference/1.0.0/csrpmessage.md) objects.

In Router 2.0.0, message headers are also fragmented, reducing the amount of overhead required for fragmented messages.

### FragmentBuffer changes

The following changes were made to the FragmentBuffer API:

- The [`Fragments`](api-reference/2.0.0/fragmentbuffer.md#csrpmessagefragment-fragments) property type has changed from [`{CsrpMessage}`](api-reference/1.0.0/csrpmessage.md) to [`{CsrpMessageFragment}`](api-reference/2.0.0/csrpmessagefragment.md).
- The [`Add`](api-reference/2.0.0/fragmentbuffer.md#void-add) method now takes a [`CsrpMessageFragment`](api-reference/2.0.0/csrpmessagefragment.md) object instead of a [`CsrpMessage`](api-reference/1.0.0/csrpmessage.md) object.

### CsrpMessage changes

The following changes were made to the CsrpMessage API:

- The [`CsrpMessage.new`](api-reference/2.0.0/csrpmessage.md#csrpmessage-new) constructor no longer accepts `fragment` or `fragmentCount` arguments.
- The [`Fragment`](api-reference/1.0.0/csrpmessage.md#number-fragment) property has been removed. Fragment information is now stored in [`CsrpMessageFragment`](api-reference/2.0.0/csrpmessagefragment.md) objects.
- The [`FragmentCount`](api-reference/1.0.0/csrpmessage.md#number-fragmentcount) property has been removed for the same reason as above.

### Message serialization and deserialization

Serialization and deserialization of messages has changed due to message fragmentation being handled differently in CSRPv2. Refer to the [new API reference](api-reference/2.0.0/csrpmessage.md#serialization) for the new format. More information on the new serialization format can be found in the [CSRPv2 specification](https://www.github.com/tenx29/roblox-csrp/tree/main/v2).

## Internal changes

Some internal changes were made to the Router API that do not affect the way the API is used. These changes require no action to be taken by the user.

- [`MessageStream`](api-reference/2.0.0/messagestream.md) now uses [`CsrpMessageFragment`](api-reference/2.0.0/csrpmessagefragment.md) objects instead of [`CsrpMessage`](api-reference/1.0.0/csrpmessage.md) objects for message buffering.
- The fragmentation algorithm used in [`Fragmenter.FragmentMessage`](api-reference/2.0.0/fragmenter.md#csrpmessagefragment-fragmentmessage) has been improved to provide a more accurate estimate of the number of fragments required to send a message.
