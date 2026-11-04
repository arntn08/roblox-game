-- Project ECLIPSE Alpha 0.1
-- Server-authoritative NPC combat with combo progression and enemy rewards.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
local attackRequest = remotes:WaitForChild("AttackRequest")
local combatFeedback = remotes:WaitForChild("CombatFeedback")

local lastAttack, comboState = {}, {}
local cooldown = GameConfig.Combat.AttackCooldown or 0.65
local range = GameConfig.Combat.AttackRange or 8
local damage = GameConfig.Combat.BaseDamage or 15

local function getEnemies()
    local found = {}
    for _, model in CollectionService:GetTagged("EclipseEnemy") do
        if model:IsA("Model") then found[model] = true end
    end
    for _, item in workspace:GetDescendants() do
        if item:IsA("Model") and item:GetAttribute("EclipseEnemy") == true then
            found[item] = true
        end
    end
    return found
end

local function findTarget(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDistance = nil, range + 0.001

    for model in getEnemies() do
        if model ~= character and model:IsDescendantOf(workspace) then
            local enemyHumanoid = model:FindFirstChildOfClass("Humanoid")
            local enemyRoot = model:FindFirstChild("HumanoidRootPart")
            if enemyHumanoid and enemyRoot and enemyHumanoid.Health > 0 then
                local offset = enemyRoot.Position - root.Position
                local distance = offset.Magnitude
                if distance <= range and distance < bestDistance and distance > 0 then
                    if root.CFrame.LookVector:Dot(offset.Unit) >= 0.15 then
                        best, bestDistance = enemyHumanoid, distance
                    end
                end
            end
        end
    end
    return best
end

attackRequest.OnServerEvent:Connect(function(player)
    local now = os.clock()
    if lastAttack[player] and now - lastAttack[player] < cooldown then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    lastAttack[player] = now

    local combo = comboState[player] or {count = 0, time = 0}
    if now - combo.time > 1.35 then combo.count = 0 end
    combo.count = combo.count % 3 + 1
    combo.time = now
    comboState[player] = combo

    local target = findTarget(character)
    local dealt = math.floor(damage * (combo.count == 3 and 1.6 or 1))
    if not target then
        combatFeedback:FireClient(player, {kind = "Swing", combo = combo.count})
        return
    end

    local enemyModel = target.Parent
    local wasAlive = target.Health > 0
    target:TakeDamage(dealt)
    local defeated = wasAlive and target.Health <= 0

    if defeated and not enemyModel:GetAttribute("EclipseRewardClaimed") then
        enemyModel:SetAttribute("EclipseRewardClaimed", true)
        local xp = enemyModel:GetAttribute("EclipseRewardXP") or 20
        local gold = enemyModel:GetAttribute("EclipseRewardGold") or 10
        PlayerDataService.AddXP(player, xp)
        PlayerDataService.AddGold(player, gold)
        combatFeedback:FireClient(player, {kind = "Reward", xp = xp, gold = gold})
    end

    combatFeedback:FireClient(player, {
        kind = "Hit",
        combo = combo.count,
        damage = dealt,
        defeated = defeated,
    })
end)

Players.PlayerRemoving:Connect(function(player)
    lastAttack[player] = nil
    comboState[player] = nil
end)

print("[ECLIPSE] Combat and reward service online.")
