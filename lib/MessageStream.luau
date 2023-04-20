--!strict
--[[
    CSRP Message Stream

    Class for handling CSRP message streams.
]]

local MessagingService = game:GetService("MessagingService")

local CsrpMessage = require(script.Parent.CsrpMessage)
local CsrpMessageBuilder = require(script.Parent.CsrpMessageBuilder)
export type CsrpMessage = CsrpMessage.CsrpMessage
export type CsrpMessageBuilder = CsrpMessageBuilder.CsrpMessageBuilder

local FragmentBuffer = require(script.Parent.FragmentBuffer)
export type FragmentBuffer = FragmentBuffer.FragmentBuffer

local Fragmenter = require(script.Parent.Fragmenter)
local Router = require(script.Parent.Router)

local MessageStream = {}
MessageStream.__index = MessageStream

local DEFAULT_MESSAGE_STREAM_TOPIC = "CSRP_GLOBAL"

MessageStream.new = function(topic: string?)
    local self = setmetatable({}, MessageStream)
    self.Topic = topic or DEFAULT_MESSAGE_STREAM_TOPIC
    local buffers: {[string]: FragmentBuffer} = {}
    self.FragmentBuffers = buffers
    return self
end

MessageStream.Send = function(self: MessageStream, message: CsrpMessage)
    local fragments = Fragmenter.FragmentMessage(message)
    for _, fragment in ipairs(fragments) do
        MessagingService:PublishAsync(self.Topic, tostring(fragment))
    end
end

-- Buffers a fragment and returns a boolean indicating whether the buffer is complete.
local function BufferFragment(self: MessageStream, fragment: CsrpMessage): boolean
    local interactionId = fragment.InteractionId
    local buffer = self.FragmentBuffers[interactionId]
    if not buffer then
        buffer = FragmentBuffer.new()
        self.FragmentBuffers[interactionId] = buffer
    end
    buffer:Add(fragment)
    return buffer:IsComplete()
end

-- Subscribes to the message stream and returns a connection.
MessageStream.Subscribe = function(self: MessageStream, callback: (CsrpMessage, number) -> nil): RBXScriptConnection
    return MessagingService:SubscribeAsync(self.Topic, function(data: {Data: string, Sent: number})
        local message = CsrpMessage.fromString(data.Data)
        -- Check if the message should be processed by the current server.
        if not Router.IsCurrentServerRecipient(message) then
            return
        end
        -- If the message has an interaction ID, it can be handled as a fragment.
        if message.InteractionId then
            local bufferIsComplete = BufferFragment(self, message)
            if bufferIsComplete then
                local defragmentedMessage = Fragmenter.DefragmentMessages(self.FragmentBuffers[message.InteractionId].Fragments)
                self.FragmentBuffers[message.InteractionId] = nil
                callback(defragmentedMessage, data.Sent)
            end
        else
            callback(message, data.Sent)
        end
    end)
end

export type MessageStream = typeof(MessageStream.new())

return MessageStream
