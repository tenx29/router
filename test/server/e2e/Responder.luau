-- Responds to end-to-end test messages
local router = script.Parent.Parent.Parent.Router
local CsrpMessage = require(router.CsrpMessage)
local CsrpMessageBuilder = require(router.CsrpMessageBuilder)
local MessageStream = require(router.MessageStream)
type CsrpMessage = CsrpMessage.CsrpMessage
type CsrpMessageBuilder = CsrpMessageBuilder.CsrpMessageBuilder
type MessageStream = MessageStream.MessageStream

return function()
    local stream: MessageStream = MessageStream.new()
    stream:Subscribe(function(message: CsrpMessage)
        -- Avoid infinite loop
        if message.Options == "response=true" then
            return
        end
        print("Responder received: "..tostring(message))
        local response = CsrpMessageBuilder.new()
            :AddRecipient(message.Sender)
            :SetOption("response", true)
            :SetBody(message.Body..".response")
            :Build()
        stream:Send(response)
    end)
end