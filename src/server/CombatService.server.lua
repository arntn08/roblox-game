-- Project ECLIPSE Alpha 0.1
-- NPC combat is validated and calculated on the server.
-- Mark enemy Models with the CollectionService tag "EclipseEnemy"
-- or set the Model attribute EclipseEnemy = true.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
local attackRequest = remotes:WaitForChild("AttackRequest")
local combatFeedback = remotes:WaitForChild("CombatFeedback")

local lastAttack = {}
local comboState = {}
local COOLDOWN = GameConfig.Combat.AttackCooldown or 0.65
local RANGE = GameConfig.Combat.AttackRange or 8
local COMBO_RESET = 1.35
local DAMAGE = GameConfig.Combat.BaseDamage or 15

local function getEnemyModels()
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

    local bestHumanoid = nil
    local bestDistance = RANGE + 0.001

    for model in getEnemyModels() do
        if not model:IsDescendantOf(workspace) or model == character then
            continue
        end
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local enemyRoot = model:FindFirstChild("HumanoidRootPart")
        if humanoid and enemyRoot and humanoid.Health > 0 then
            local offset = enemyRoot.Position - root.Position
            local distance = offset.Magnitude
            if distance <= RANGE and distance < bestDistance then
                if root.CFrame.LookVector:Dot(offset.Unit) >= 0.15 then
                    bestDistance = distance
                    bestHumanoid = humanoid
                end
            end
        end
    end
    return bestHumanoid
end

attackRequest.OnServerEvent:Connect(function(player)
    local now = os.clock()
    if lastAttack[player] and now - lastAttack[player] < COOLDOWN then return end

    local character = player.Character
    if not character then return end
    local playerHumanoid = character:FindFirstChildOfClass("Humanoid")
    if not playerHumanoid or playerHumanoid.Health <= 0 then return end

    lastAttack[player] = now
    local state = comboState[player] or {count = 0, time = 0}
    if now - state.time > COMBO_RESET then state.count = 0 end
    state.count = (state.count % 3) + 1
    state.time = now
    comboState[player] = state

    local dealtDamage = math.floor(DAMAGE * (state.count == 3 and 1.6 or 1))
    local target = findTarget(character)
    if target then
        target:TakeDamage(dealtDamage)
        combatFeedback:FireClient(player, {
            kind = "Hit",
            combo = state.count,
            damage = dealtDamage,
            defeated = target.Health <= 0,
        })
    else
        combatFeedback:FireClient(player, {kind = "Swing", combo = state.count})
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastAttack[player] = nil
    comboState[player] = nil
end)

print("[ECLIPSE] Combat service online. Three-hit combo enabled.")
