-- Project ECLIPSE Alpha 0.1
-- Client-side startup. Mobile UI and input will be added in later steps.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

print(string.format(
    "[%s] Client initialized — %s",
    GameConfig.GameName,
    GameConfig.Version
))
