-- Chat listener for performing end-to-end tests
-- Requires two game instances to be running
-- Run the e2e tests by typing "!test <payload>" in the chat
-- Report will be printed to the server console
-- Note: The command can only be run by the game creator
local Players = game:GetService("Players")

local Runner = require(script.Parent.Parent.testlib.Runner)
local EndToEndTests = script.Parent

local prefix = "!test"

local function onMessageReceived(message: string)
    if message:lower():split(" ")[1] ~= prefix then
        return
    end
    local payload = message:sub(#prefix + 2)
    local env = {
        payload = payload,
    }
    print(string.rep("=", 80))
    print("Beginning end-to-end tests with payload: "..payload)
    local report = Runner.Run(EndToEndTests, env)
    print(report)
    print(string.rep("=", 80))
end

return function()
    for _, player in ipairs(Players:GetPlayers()) do
        local userId = player.UserId
        if userId ~= game.CreatorId and game.CreatorId ~= 0 then
            return
        end
        player.Chatted:Connect(onMessageReceived)
    end
    Players.PlayerAdded:Connect(function(player)
        local userId = player.UserId
        if userId ~= game.CreatorId and game.CreatorId ~= 0 then
            return
        end
        player.Chatted:Connect(onMessageReceived)
    end)
    print("End-to-end tests loaded")
end