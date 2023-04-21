--!strict
local CsrpMessage = require(script.Parent.CsrpMessage)
type CsrpMessage = CsrpMessage.CsrpMessage

local Fragmenter = {}
local MAX_MESSAGE_SIZE = 1000

Fragmenter.FragmentMessage = function(message: CsrpMessage): {CsrpMessage}
	if #tostring(message) <= MAX_MESSAGE_SIZE then
		return {message}
	else
		local fragments: {CsrpMessage} = {}
		local sections = tostring(message):split(";")
		local headerSections = {}
		table.move(sections, 1, 6, 1, headerSections)
		local header = table.concat(headerSections, ";")..";"
		local body = table.concat(sections, ";", 7)
		assert(#header < MAX_MESSAGE_SIZE, "Message header exceeds fragment length limit")
		
		-- Calculate the overhead needed for the fragment labels
		local maxBodyLength = MAX_MESSAGE_SIZE - #header
		local minFragments = math.floor(#body/maxBodyLength)	    -- very rough estimate of the number of fragments needed
		local maxFragLength = math.ceil(math.log10(minFragments)+1)*2	-- maximum characters taken up by the fragment headers (both order and count)
		
		assert(#header + maxFragLength < MAX_MESSAGE_SIZE, "Message too long to include fragment headers")
		
		-- Fragment the message
		local fragBodyLength = MAX_MESSAGE_SIZE - #header - maxFragLength
		for i = 1, #body, fragBodyLength do
			table.insert(fragments, CsrpMessage.fromString(header..body:sub(i, i+fragBodyLength-1)))
		end
		
		-- Add fragment labels
		for i, fragment in fragments do
			fragment.Fragment = i
			fragment.FragmentCount = #fragments
		end
		
		return fragments
	end
end

Fragmenter.DefragmentMessages = function(messages: {CsrpMessage}): CsrpMessage
	-- Prepare header
	local first = messages[1]
	local origin = first.Sender
	local target = first.Recipients
	local id = first.InteractionId
	local options = first.Options
	local body = ""
	
	-- Sort the input table by fragment number
	table.sort(messages, function(a, b)
		local aFrag = a.Fragment or a.FragmentCount or 1
		local bFrag = b.Fragment or b.FragmentCount or 1
		return aFrag < bFrag
	end)
	
	-- Concatenate the fragmented data
	for _, fragment in messages do
		body ..= fragment.Body or ""
	end
	return CsrpMessage.new(origin, target, id, nil, nil, options, body)
end

export type Fragmenter = typeof(Fragmenter)

return Fragmenter
