-- Project ECLIPSE Alpha 0.1
-- Session-only player data foundation.
-- Persistent DataStore saving will be added in a later milestone.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CharacterConfig = require(Shared:WaitForChild("CharacterConfig"))

local PlayerDataService = {}
local sessionData = {}

local function createLeaderstats(player, data)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local level = Instance.new("IntValue")
    level.Name = "Level"
    level.Value = data.Level
    level.Parent = leaderstats

    local gold = Instance.new("IntValue")
    gold.Name = "Gold"
    gold.Value = data.Gold
    gold.Parent = leaderstats
end

function PlayerDataService.InitializePlayer(player)
    if sessionData[player] then
        return sessionData[player]
    end

    local defaults = CharacterConfig.Defaults
    local data = {
        Level = defaults.Level,
        XP = defaults.XP,
        Gold = defaults.Gold,
        MaxHealth = defaults.MaxHealth,
        BaseDamage = defaults.BaseDamage,
        Defense = defaults.Defense,
    }

    sessionData[player] = data
    createLeaderstats(player, data)

    player:SetAttribute("EclipseLevel", data.Level)
    player:SetAttribute("EclipseXP", data.XP)
    player:SetAttribute("EclipseXPToNextLevel", CharacterConfig.GetXPToNextLevel(data.Level))
    player:SetAttribute("EclipseGold", data.Gold)
    player:SetAttribute("EclipseBaseDamage", data.BaseDamage)
    player:SetAttribute("EclipseDefense", data.Defense)

    return data
end

function PlayerDataService.GetData(player)
    return sessionData[player]
end

function PlayerDataService.AddXP(player, amount)
    local data = sessionData[player]
    amount = math.floor(tonumber(amount) or 0)

    if not data or amount <= 0 then
        return false
    end

    data.XP += amount

    while data.XP >= CharacterConfig.GetXPToNextLevel(data.Level) do
        data.XP -= CharacterConfig.GetXPToNextLevel(data.Level)
        data.Level += 1
    end

    player:SetAttribute("EclipseLevel", data.Level)
    player:SetAttribute("EclipseXP", data.XP)
    player:SetAttribute("EclipseXPToNextLevel", CharacterConfig.GetXPToNextLevel(data.Level))

    local leaderstats = player:FindFirstChild("leaderstats")
    local levelValue = leaderstats and leaderstats:FindFirstChild("Level")
    if levelValue then
        levelValue.Value = data.Level
    end

    return true
end

function PlayerDataService.AddGold(player, amount)
    local data = sessionData[player]
    amount = math.floor(tonumber(amount) or 0)

    if not data or amount <= 0 then
        return false
    end

    data.Gold += amount
    player:SetAttribute("EclipseGold", data.Gold)

    local leaderstats = player:FindFirstChild("leaderstats")
    local goldValue = leaderstats and leaderstats:FindFirstChild("Gold")
    if goldValue then
        goldValue.Value = data.Gold
    end

    return true
end

function PlayerDataService.RemovePlayer(player)
    sessionData[player] = nil
end

return PlayerDataService
