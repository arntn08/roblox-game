-- Project ECLIPSE Alpha 0.1
-- Persistent progression. Enable Studio API access for test places; failures fall back safely to defaults.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CharacterConfig = require(Shared:WaitForChild("CharacterConfig"))

local PlayerDataService = {}
local sessionData = {}
local store = DataStoreService:GetDataStore("ProjectECLIPSE_PlayerData_v1")

local function keyFor(player)
    return "Player_" .. tostring(player.UserId)
end

local function createLeaderstats(player, data)
    local leaderstats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    local level = leaderstats:FindFirstChild("Level") or Instance.new("IntValue")
    level.Name = "Level"; level.Value = data.Level; level.Parent = leaderstats
    local gold = leaderstats:FindFirstChild("Gold") or Instance.new("IntValue")
    gold.Name = "Gold"; gold.Value = data.Gold; gold.Parent = leaderstats
end

local function publish(player, data)
    player:SetAttribute("EclipseLevel", data.Level)
    player:SetAttribute("EclipseXP", data.XP)
    player:SetAttribute("EclipseXPToNextLevel", CharacterConfig.GetXPToNextLevel(data.Level))
    player:SetAttribute("EclipseGold", data.Gold)
    player:SetAttribute("EclipseBaseDamage", data.BaseDamage)
    player:SetAttribute("EclipseDefense", data.Defense)
    createLeaderstats(player, data)
end

function PlayerDataService.InitializePlayer(player)
    if sessionData[player] then return sessionData[player] end
    local defaults = CharacterConfig.Defaults
    local data = {
        Level=defaults.Level, XP=defaults.XP, Gold=defaults.Gold,
        MaxHealth=defaults.MaxHealth, BaseDamage=defaults.BaseDamage, Defense=defaults.Defense,
    }
    local success, saved = pcall(function()
        return store:GetAsync(keyFor(player))
    end)
    if success and typeof(saved)=="table" then
        data.Level=math.max(1,math.floor(tonumber(saved.Level) or data.Level))
        data.XP=math.max(0,math.floor(tonumber(saved.XP) or data.XP))
        data.Gold=math.max(0,math.floor(tonumber(saved.Gold) or data.Gold))
    elseif not success then
        warn("[ECLIPSE] Data load failed for "..player.Name.."; using session defaults.")
    end
    sessionData[player]=data
    publish(player,data)
    return data
end

function PlayerDataService.GetData(player)
    return sessionData[player]
end

function PlayerDataService.AddXP(player, amount)
    local data=sessionData[player]
    amount=math.floor(tonumber(amount) or 0)
    if not data or amount<=0 then return false end
    data.XP+=amount
    while data.XP>=CharacterConfig.GetXPToNextLevel(data.Level) do
        data.XP-=CharacterConfig.GetXPToNextLevel(data.Level)
        data.Level+=1
    end
    publish(player,data)
    return true
end

function PlayerDataService.AddGold(player, amount)
    local data=sessionData[player]
    amount=math.floor(tonumber(amount) or 0)
    if not data or amount<=0 then return false end
    data.Gold+=amount
    publish(player,data)
    return true
end

function PlayerDataService.SavePlayer(player)
    local data=sessionData[player]
    if not data then return false end
    local snapshot={Level=data.Level,XP=data.XP,Gold=data.Gold,Version=1,UpdatedAt=os.time()}
    local success,err=pcall(function()
        store:SetAsync(keyFor(player),snapshot)
    end)
    if not success then
        warn("[ECLIPSE] Data save failed for "..player.Name..": "..tostring(err))
        return false
    end
    return true
end

function PlayerDataService.RemovePlayer(player)
    PlayerDataService.SavePlayer(player)
    sessionData[player]=nil
end

game:BindToClose(function()
    for _,player in Players:GetPlayers() do
        PlayerDataService.SavePlayer(player)
    end
    task.wait(2)
end)

return PlayerDataService
