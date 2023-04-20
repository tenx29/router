--!strict
local CsrpMessage = require(script.Parent.CsrpMessage)
type CsrpMessage = CsrpMessage.CsrpMessage
local Router = {}

-- Check if a message was sent by the current server
Router.IsCurrentServerSender = function(message: CsrpMessage | string): boolean
	if typeof(message) == "string" then
		message = CsrpMessage.fromString(message)
	end
	return (message::CsrpMessage).Sender == game.JobId
end

-- Check if a message is supposed to be processed by the current server
Router.IsCurrentServerRecipient = function(message: CsrpMessage | string): boolean
	if typeof(message) == "string" then
		message = CsrpMessage.fromString(message)
	end
	local recipients: {string} = (message::CsrpMessage).Recipients:split(",")
    local jobId = game.JobId or "localhost"
	local include: boolean? = nil
	for _, recipient in recipients do
		if (recipient == jobId or recipient == "") and include == nil then
			include = true
		elseif recipient:sub(1,1) == "-" and recipient:sub(2) == jobId then
			include = false
        elseif recipient == "-" then
            return false
		end
	end
	return include or false
end

return Router