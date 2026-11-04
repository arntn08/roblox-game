-- Server-owned starter inventory and class-locked equipment.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Shared=ReplicatedStorage:WaitForChild("Shared")
local WeaponConfig=require(Shared:WaitForChild("WeaponConfig"))
local ClassConfig=require(Shared:WaitForChild("ClassConfig"))
local remotes=ReplicatedStorage:WaitForChild("EclipseRemotes")
local equipRequest=remotes:WaitForChild("EquipRequest")
local inventoryFeedback=remotes:WaitForChild("InventoryFeedback")

local function setup(player)
    local folder=player:FindFirstChild("EclipseInventory") or Instance.new("Folder")
    folder.Name="EclipseInventory"
    folder.Parent=player
    for weaponName,weapon in WeaponConfig.Weapons do
        local item=folder:FindFirstChild(weaponName)
        if not item then
            item=Instance.new("BoolValue")
            item.Name=weaponName
            item.Value=true
            item.Parent=folder
        end
    end
end

local function equip(player, weaponName)
    if typeof(weaponName)~="string" then return end
    local weapon=WeaponConfig.Weapons[weaponName]
    local inventory=player:FindFirstChild("EclipseInventory")
    local owned=inventory and inventory:FindFirstChild(weaponName)
    local className=player:GetAttribute("EclipseClass") or ClassConfig.DefaultClass
    local class=ClassConfig.Classes[className]
    if not weapon or not owned or not owned.Value or not class or weapon.Class~=className then
        inventoryFeedback:FireClient(player,{kind="Rejected",message="This weapon is not available to your class."})
        return
    end
    player:SetAttribute("EclipseWeapon",weaponName)
    player:SetAttribute("EclipseBaseDamage",class.Damage+weapon.DamageBonus)
    inventoryFeedback:FireClient(player,{kind="Equipped",weapon=weaponName,damage=class.Damage+weapon.DamageBonus})
end

equipRequest.OnServerEvent:Connect(equip)
Players.PlayerAdded:Connect(setup)
for _,player in Players:GetPlayers() do task.spawn(setup,player) end
print("[ECLIPSE] Inventory and equipment service online.")
