--!strict
--[[
	CSRP Message Builder

	Utility for building valid CSRP messages.
	
	Sections must be separated with a semicolon. (;)
	
	Typical maximum length for messages is 1024 bytes due to MessagingService limits.
	
	Sender server ID					|Recipient server ID(s)				 |Interaction ID
	xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx;yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy;zzzzzzzz-zzzz-zzzz-zzzzzzzzzzzz;
	
	Fragment number	|Fragment count	 |Options					   |Body
	0000000000000000;9999999999999999;exampleOption=value,option2=0;Example message here
]]

local HttpService = game:GetService("HttpService")

local CsrpMessage = require(script.Parent.CsrpMessage)
export type CsrpMessage = CsrpMessage.CsrpMessage

local CsrpMessageBuilder = {}
CsrpMessageBuilder.__index = CsrpMessageBuilder

CsrpMessageBuilder.new = function(): CsrpMessageBuilder
	local self = setmetatable({}, CsrpMessageBuilder)
	self.Sender = game.JobId
	self.Recipients = {}
	self.InteractionId = HttpService:GenerateGUID(false)
	local options: {[string]: any} = {}
	self.Options = options
	local body: string = nil
	self.Body = body
	return self
end

CsrpMessageBuilder.SetSender = function(self: CsrpMessageBuilder, sender: string): CsrpMessageBuilder
	assert(sender:find(";") == nil, "Illegal character (;) in sender: "..sender)
	self.Sender = sender
	return self
end

CsrpMessageBuilder.SetRecipients = function(self: CsrpMessageBuilder, recipients: {string}): CsrpMessageBuilder
	for _, recipient in ipairs(recipients) do
		assert(recipient:find(";") == nil, "Illegal character (;) in recipient: "..recipient)
	end
	self.Recipients = recipients
	return self
end

CsrpMessageBuilder.AddRecipient = function(self: CsrpMessageBuilder, recipient: string): CsrpMessageBuilder
	assert(recipient:find(";") == nil, "Illegal character (;) in recipient: "..recipient)
	table.insert(self.Recipients, recipient)
	return self
end

CsrpMessageBuilder.ExcludeRecipient = function(self: CsrpMessageBuilder, recipient: string): CsrpMessageBuilder
	assert(recipient:find(";") == nil, "Illegal character (;) in recipient: "..recipient)
	if recipient:sub(1, 1) == "-" then
		warn(`Excluded recipient id "{recipient}" starts with a hyphen resulting in two hyphens in a row. This may not be intended.`)
	end
	table.insert(self.Recipients, "-"..recipient)
	return self
end

CsrpMessageBuilder.SetInteractionId = function(self: CsrpMessageBuilder, id: string)
	assert(id:find(";") == nil, "Illegal character (;) in interaction ID: "..id)
	self.InteractionId = id
	return self
end

CsrpMessageBuilder.SetOption = function(self: CsrpMessageBuilder, option: string, value: any): CsrpMessageBuilder
	assert(option:find("=") == nil, "Illegal character (=) in option name: "..option)
	assert(option:find(",") == nil, "Illegal character (,) in option name: "..option)
	assert(option:find(";") == nil, "Illegal character (;) in option name: "..option)
	assert(tostring(value):find("=") == nil, "Illegal character (=) in option value: "..tostring(value))
	assert(tostring(value):find(",") == nil, "Illegal character (,) in option value: "..tostring(value))
	assert(tostring(value):find(";") == nil, "Illegal character (;) in option value: "..tostring(value))
	self.Options[option] = value
	return self
end

CsrpMessageBuilder.SetBody = function(self: CsrpMessageBuilder, body: any?): CsrpMessageBuilder
	self.Body = tostring(body)
	return self
end

CsrpMessageBuilder.Build = function(self: CsrpMessageBuilder): CsrpMessage
	return CsrpMessage.new(self.Sender, self.Recipients, self.InteractionId, nil, nil, self.Options, self.Body)
end

export type CsrpMessageBuilder = typeof(CsrpMessageBuilder.new())

return CsrpMessageBuilder
