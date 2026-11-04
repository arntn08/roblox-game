-- Project ECLIPSE Alpha 0.1
-- Server-authoritative skill damage. Clients may request a skill name only.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local SkillConfig = require(Shared:WaitForChild("SkillConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local QuestService = require(script.Parent:WaitForChild("QuestService"))

local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
local skillRequest = remotes:WaitForChild("SkillRequest")
local skillFeedback = remotes:WaitForChild("SkillFeedback")

local cooldowns = {}

local function getEnemyFromPart(part)
    local current = part
    while current and current ~= workspace do
        if current:IsA("Model") then
            local humanoid = current:FindFirstChildOfClass("Humanoid")
            if humanoid and (current:GetAttribute("EclipseEnemy") == true
                or CollectionService:HasTag(current, "EclipseEnemy")) then
                return current, humanoid
            end
        end
        current = current.Parent
    end
    return nil, nil
end

local function showEffect(position, radius, color)
    local effect = Instance.new("Part")
    effect.Name = "EclipseSkillEffect"
    effect.Shape = Enum.PartType.Ball
    effect.Anchored = true
    effect.CanCollide = false
    effect.CanTouch = false
    effect.CanQuery = false
    effect.Material = Enum.Material.Neon
    effect.Color = color
    effect.Transparency = 0.45
    effect.Size = Vector3.new(1, 1, 1)
    effect.CFrame = CFrame.new(position)
    effect.Parent = workspace

    local tween = TweenService:Create(
        effect,
        TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = Vector3.new(radius * 2, radius * 2, radius * 2), Transparency = 1}
    )
    tween:Play()
    Debris:AddItem(effect, 0.45)
end

local function rewardDefeat(player, enemy)
    if enemy:GetAttribute("EclipseRewardClaimed") then return end
    enemy:SetAttribute("EclipseRewardClaimed", true)
    local xp = enemy:GetAttribute("EclipseRewardXP") or 20
    local gold = enemy:GetAttribute("EclipseRewardGold") or 10
    PlayerDataService.AddXP(player, xp)
    PlayerDataService.AddGold(player, gold)
        QuestService.RegisterDefeat(player)
    skillFeedback:FireClient(player, {kind = "Reward", xp = xp, gold = gold})
end

local function collectTargets(character, root, skill)
    local boxCFrame
    local boxSize

    if skill.Shape == "Forward" then
        boxCFrame = root.CFrame * CFrame.new(0, 0, -(skill.Range / 2 + 2))
        boxSize = Vector3.new(skill.Radius * 2, 9, skill.Range)
    else
        boxCFrame = root.CFrame
        boxSize = Vector3.new(skill.Radius * 2, skill.Radius * 2, skill.Radius * 2)
    end

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}

    local targets = {}
    for _, part in workspace:GetPartBoundsInBox(boxCFrame, boxSize, params) do
        local enemy, humanoid = getEnemyFromPart(part)
        if enemy and humanoid and humanoid.Health > 0 then
            targets[enemy] = humanoid
        end
    end
    return targets
end

skillRequest.OnServerEvent:Connect(function(player, skillName)
    if typeof(skillName) ~= "string" then return end
    local skill = SkillConfig.Skills[skillName]
    if not skill then return end

    local character = player.Character
    local playerHumanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not playerHumanoid or playerHumanoid.Health <= 0 or not root then return end

    cooldowns[player] = cooldowns[player] or {}
    local now = os.clock()
    local readyAt = cooldowns[player][skillName] or 0
    if now < readyAt then
        skillFeedback:FireClient(player, {kind = "Cooldown", skill = skillName, remaining = readyAt - now})
        return
    end
    cooldowns[player][skillName] = now + skill.Cooldown

    local baseDamage = player:GetAttribute("EclipseBaseDamage") or GameConfig.Combat.BaseDamage
    local dealtDamage = math.floor(baseDamage * skill.DamageMultiplier)
    local targets = collectTargets(character, root, skill)
    local hitCount = 0

    for enemy, enemyHumanoid in targets do
        if enemyHumanoid.Health > 0 then
            enemyHumanoid:TakeDamage(dealtDamage)
            hitCount += 1
            if enemyHumanoid.Health <= 0 then
                rewardDefeat(player, enemy)
            end
        end
    end

    showEffect(root.Position + root.CFrame.LookVector * (skill.Shape == "Forward" and 6 or 0), skill.Radius, skill.Color)
    skillFeedback:FireClient(player, {
        kind = "Used",
        skill = skillName,
        hits = hitCount,
        damage = dealtDamage,
        cooldown = skill.Cooldown,
    })
end)

Players.PlayerRemoving:Connect(function(player)
    cooldowns[player] = nil
end)

print("[ECLIPSE] Three-skill ability service online.")
