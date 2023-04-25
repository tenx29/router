--!strict
local CsrpMessage = require(script.Parent.CsrpMessage)
type CsrpMessage = CsrpMessage.CsrpMessage

local CsrpMessageFragment = require(script.Parent.CsrpMessageFragment)
type CsrpMessageFragment = CsrpMessageFragment.CsrpMessageFragment

local Fragmenter = {}
local MAX_MESSAGE_SIZE: number = 1000

Fragmenter.FragmentMessage = function(message: CsrpMessage, maxLength: number?): {CsrpMessageFragment}
	maxLength = maxLength or MAX_MESSAGE_SIZE
	if #tostring(message) <= maxLength::number then
		return {CsrpMessageFragment.new(message.InteractionId, 1, 1, message:fragmentableToString())}
	else
		local fragments: {CsrpMessageFragment} = {}
		local interactionId = message.InteractionId
		local fragmentableString = message:fragmentableToString()

		-- Calculate the overhead needed for the fragment labels using the new CSRPv2 format
		-- as well as an improved fragment allocation algorithm
		
		-- Number of characters taken up by interactionId and 3 semicolons
		local fragHeaderLength = #interactionId + 3

		-- Max number of characters taken up by the fragment and fragment count
		local allocatedNumberLength = 2 * math.floor(math.log10(#fragmentableString))

		-- Throw an error if too much space is taken up by the fragment labels
		assert(fragHeaderLength + allocatedNumberLength < maxLength::number, "Fragment labels exceed fragment length limit")

		-- Number of characters available for the body
		local maxBodyLength = maxLength::number - fragHeaderLength - allocatedNumberLength

		-- Number of fragments required to send the message
		local fragmentCount = math.ceil(#fragmentableString / maxBodyLength)

		-- Calculate the length of each fragment
		local fragmentLength = math.ceil(#fragmentableString / fragmentCount)

		-- Split the message into fragments
		for i = 1, fragmentCount do
			local fragment = fragmentableString:sub((i - 1) * fragmentLength + 1, i * fragmentLength)
			local fragmentMessage = CsrpMessageFragment.new(interactionId, i, fragmentCount, fragment)
			table.insert(fragments, fragmentMessage)
		end
		
		return fragments
	end
end

Fragmenter.DefragmentMessages = function(messages: {CsrpMessageFragment}): CsrpMessage
	-- Prepare header
	local first = messages[1]
	local interactionId = first.InteractionId
	local content = ""
	
	-- Sort the input table by fragment number
	table.sort(messages, function(a, b)
		local aFrag = a.Fragment or a.FragmentCount or 1
		local bFrag = b.Fragment or b.FragmentCount or 1
		return aFrag < bFrag
	end)
	
	-- Concatenate the fragmented data
	for _, fragment in messages do
		content ..= fragment.Content
	end
	return CsrpMessage.fromString(`{interactionId};;;{content}`)
end

export type Fragmenter = typeof(Fragmenter)

return Fragmenter
