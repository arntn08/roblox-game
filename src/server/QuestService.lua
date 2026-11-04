-- Session-only repeatable defeat quest. Called by combat and skill reward paths.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuestService = {}
local progress = {}
local TARGET = 5
local XP_REWARD = 100
local GOLD_REWARD = 75

function QuestService.RegisterDefeat(player)
    local state = progress[player] or {Count=0, Completed=0}
    state.Count += 1
    local completed = false
    if state.Count >= TARGET then
        state.Count = 0
        state.Completed += 1
        completed = true
    end
    progress[player] = state
    local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
    local feedback = remotes:FindFirstChild("QuestFeedback")
    if completed then
        local dataService = require(script.Parent:WaitForChild("PlayerDataService"))
        dataService.AddXP(player, XP_REWARD)
        dataService.AddGold(player, GOLD_REWARD)
    end
    if feedback then
        feedback:FireClient(player, {kind=completed and "Completed" or "Progress", count=state.Count, target=TARGET, xp=completed and XP_REWARD or 0, gold=completed and GOLD_REWARD or 0, completed=state.Completed})
    end
end

function QuestService.RemovePlayer(player)
    progress[player] = nil
end
return QuestService
