-- Server-controlled class selection and starter weapon assignment.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ClassConfig"))
local WeaponConfig = require(ReplicatedStorage.Shared:WaitForChild("WeaponConfig"))
local remote = ReplicatedStorage:WaitForChild("EclipseRemotes"):WaitForChild("ClassRequest")

local function applyClass(player, className)
    local class = ClassConfig.Classes[className]
    if not class then return end
    local weapon = WeaponConfig.Weapons[class.Weapon]
    player:SetAttribute("EclipseClass", className)
    player:SetAttribute("EclipseWeapon", class.Weapon)
    player:SetAttribute("EclipseBaseDamage", class.Damage + weapon.DamageBonus)
    player:SetAttribute("EclipseDefense", class.Defense)
    player:SetAttribute("EclipseMaxHealth", class.MaxHealth)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = class.MaxHealth
        humanoid.Health = class.MaxHealth
    end
    remote:FireClient(player, {kind="Selected", class=className, weapon=class.Weapon})
end

remote.OnServerEvent:Connect(function(player, className)
    if typeof(className) ~= "string" or not ClassConfig.Classes[className] then return end
    -- Selection is permitted at any time in this prototype; later add a class-change NPC/cost.
    applyClass(player, className)
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.25)
        local chosen = player:GetAttribute("EclipseClass") or ClassConfig.DefaultClass
        local class = ClassConfig.Classes[chosen]
        if class then
            player:SetAttribute("EclipseClass", chosen)
            player:SetAttribute("EclipseWeapon", class.Weapon)
            local weapon = WeaponConfig.Weapons[class.Weapon]
            player:SetAttribute("EclipseBaseDamage", class.Damage + weapon.DamageBonus)
            player:SetAttribute("EclipseDefense", class.Defense)
            player:SetAttribute("EclipseMaxHealth", class.MaxHealth)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.MaxHealth=class.MaxHealth; humanoid.Health=class.MaxHealth end
        end
    end)
end)
print("[ECLIPSE] Class selection service online.")
