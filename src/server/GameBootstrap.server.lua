-- Project ECLIPSE Alpha 0.1
-- Server-side startup. Server is authoritative for gameplay.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local remotesFolder = ReplicatedStorage:FindFirstChild("EclipseRemotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "EclipseRemotes"
    remotesFolder.Parent = ReplicatedStorage
end

print(string.format(
    "[%s] Server initialized — %s",
    GameConfig.GameName,
    GameConfig.Version
))
