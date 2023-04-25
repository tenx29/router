--!strict
--[[
	CSRP Message Fragment
	
	Message fragment class following the CSRPv2 specification.
]]

local CsrpMessageFragment = {}
CsrpMessageFragment.__index = CsrpMessageFragment

CsrpMessageFragment.new = function(interactionId: string?, fragment: number?, fragmentCount: number?, content: string?): CsrpMessageFragment
    if interactionId then
        assert(interactionId:find(";") == nil, "Illegal character (;) in interaction ID: "..interactionId)
    end
    if fragment or fragmentCount then
        assert(interactionId ~= nil, "Interaction ID must be specified for fragmented messages")
    end
    local self = setmetatable({}, CsrpMessageFragment)
    self.InteractionId = if interactionId == "" then nil else interactionId
    self.Fragment = fragment
    self.FragmentCount = fragmentCount
    self.Content = content or ""
    return self
end

CsrpMessageFragment.fromString = function(message: string): CsrpMessageFragment
    local sections = message:split(";")
    local interactionId = sections[1]
    local fragment = sections[2]
    local fragmentCount = sections[3]
    local content = table.concat(sections, ";", 4)
    assert(#sections >= 4, "Failed to parse fragment: sections missing")
    return CsrpMessageFragment.new(interactionId, tonumber(fragment), tonumber(fragmentCount), content)
end

CsrpMessageFragment.__tostring = function(self: CsrpMessageFragment): string
    return `{self.InteractionId or ""};{self.Fragment or ""};{self.FragmentCount or ""};{self.Content or ""}`
end

export type CsrpMessageFragment = typeof(CsrpMessageFragment.new("", 0, 0, ""))

return CsrpMessageFragment
