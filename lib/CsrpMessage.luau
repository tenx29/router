--!strict
--[[
	CSRP Message
	
	Sections must be separated with a semicolon. (;)
	
	Typical maximum length for messages is 1000 bytes due to MessagingService limits.
	
	Sender server ID					|Recipient server ID(s)				 |Interaction ID
	xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx;yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy;zzzzzzzz-zzzz-zzzz-zzzzzzzzzzzz;
	
	Fragment number	|Fragment count	 |Options					   |Body
	0000000000000000;9999999999999999;exampleOption=value,option2=0;Example message here
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

CsrpMessage.new = function(sender: string?, recipients: {string} | string?, interactionId: string, fragment: number?, fragmentCount: number?, options: {[string]: any} | string?, body: string?): CsrpMessage
	local self = setmetatable({}, CsrpMessage)
	self.Sender = validateSectionString(sender or game.JobId)
	self.Recipients = validateSectionString(recipientsToString(recipients))
	self.InteractionId = validateSectionString(interactionId)
	self.Fragment = fragment
	self.FragmentCount = fragmentCount
	self.Options = optionsToString(options)
	self.Body = body
	return self
end

-- Parse a CSP message string and convert it to a CsrpMessage object
CsrpMessage.fromString = function(message: string): CsrpMessage
	local sections = message:split(";")
	assert(#sections >= 7, "Failed to parse message: sections missing")
	local sender = sections[1]
	local recipients = sections[2]
	local interactionId = sections[3]
	local fragment = if #sections[4] > 0 then tonumber(sections[4]) else nil
	local fragmentCount = if #sections[5] > 0 then tonumber(sections[5]) else nil
	local options = sections[6]
	local concatBody = table.concat(sections, ";", 7)
	local body = if #concatBody == 0 then nil else concatBody
	return CsrpMessage.new(sender, recipients, interactionId, fragment, fragmentCount, options, body)
end

-- Convert a CsrpMessage object to a string
CsrpMessage.__tostring = function(self: CsrpMessage)
	local sender = self.Sender
	local recipients = self.Recipients
	local interactionId = self.InteractionId
	local fragment = tostring(self.Fragment or "")
	local fragmentCount = tostring(self.FragmentCount or "")
	local options = self.Options
	local body = self.Body or ""
	return `{sender};{recipients};{interactionId};{fragment};{fragmentCount};{options};{body}`
end

export type CsrpMessage = typeof(CsrpMessage.new("", nil, "", nil, nil, nil, nil))

return CsrpMessage
