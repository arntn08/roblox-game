local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local remotes = ReplicatedStorage:FindFirstChild("EclipseRemotes")
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = "EclipseRemotes"
    remotes.Parent = ReplicatedStorage
end

for _, name in {"AttackRequest", "CombatFeedback"} do
    if not remotes:FindFirstChild(name) then
        local event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = remotes
    end
end

print(GameConfig.GameName .. " " .. GameConfig.Version .. " server ready")
