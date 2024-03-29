--!strict
--[[
	CSRP Message
	
	Sections must be separated with a semicolon. (;)
	
	Typical maximum length for messages is 1000 bytes due to MessagingService limits.
	
	Interaction ID				   |Fragment number	|Fragment count
	zzzzzzzz-zzzz-zzzz-zzzzzzzzzzzz;0000000000000000;9999999999999999;
	
	Sender server ID	|Recipient server ID(s)	 |Options
	xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx;yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy
	
	|Body
	;exampleOption=value,option2=0;Example message here
]]


local CsrpMessage = {}
CsrpMessage.__index = CsrpMessage

-- Make sure a section string contains no characters that would interfere with CsrpMessage parsing
local function validateSectionString(value: string): string
	assert(value:find(";") == nil, "Illegal character (;) in section: "..value)
	return value
end

-- Convert recipients to the correct format
local function recipientsToString(recipients: {string} | string?): string
	if not recipients then
		return ""
	elseif typeof(recipients) == "string" then
		return recipients
	else
		return table.concat(recipients, ",")
	end
end

-- Convert options dictionary to a string
local function optionsToString(options: {[string]: any} | string?): string
	if not options then
		return ""
	elseif typeof(options) == "string" then
		return validateSectionString(options)
	else
		local result = ""
		for key, value in pairs(options) do
			if #result > 0 then
				result ..= ","
			end
			local success = pcall(function()
				result ..= key .. "=" .. tostring(value)
			end)
			if not success then
				error(`Unable to serialize option "{key}"`)
			end
		end
		return validateSectionString(result)
	end
end

CsrpMessage.new = function(sender: string?, recipients: {string} | string?, interactionId: string, options: {[string]: any} | string?, body: string?): CsrpMessage
	local self = setmetatable({}, CsrpMessage)
	self.Sender = validateSectionString(sender or game.JobId)
	self.Recipients = validateSectionString(recipientsToString(recipients))
	self.InteractionId = validateSectionString(interactionId)
	self.Options = optionsToString(options)
	self.Body = body
	return self
end

-- Parse a CSP message string and convert it to a CsrpMessage object
CsrpMessage.fromString = function(message: string): CsrpMessage
	local sections = message:split(";")
	assert(#sections >= 5, "Failed to parse message: sections missing")
	local interactionId = sections[1]
	local sender = sections[2]
	local recipients = sections[3]
	local options = sections[4]
	local concatBody = table.concat(sections, ";", 5)
	local body = if #concatBody == 0 then nil else concatBody
	return CsrpMessage.new(sender, recipients, interactionId, options, body)
end

-- Convert a CsrpMessage object to a string
CsrpMessage.__tostring = function(self: CsrpMessage)
	local sender = self.Sender
	local recipients = self.Recipients
	local interactionId = self.InteractionId
	local options = self.Options
	local body = self.Body or ""
	return `{interactionId};{sender};{recipients};{options};{body}`
end

-- Convert all fragmentable fields to a string
CsrpMessage.fragmentableToString = function(self: CsrpMessage)
	local sender = self.Sender
	local recipients = self.Recipients
	local options = self.Options
	local body = self.Body or ""
	return `{sender};{recipients};{options};{body}`
end

export type CsrpMessage = typeof(CsrpMessage.new("", nil, "", nil, nil))

return CsrpMessage
