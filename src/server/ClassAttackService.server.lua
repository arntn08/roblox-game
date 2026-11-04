-- Server-authoritative class weapon attacks: mage bolt and archer arrow.
-- Swordsman continues to use the existing three-hit melee combo.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local CollectionService=game:GetService("CollectionService")
local remote=ReplicatedStorage:WaitForChild("EclipseRemotes"):WaitForChild("ClassAttackRequest")
local feedback=ReplicatedStorage.EclipseRemotes:WaitForChild("ClassAttackFeedback")
local cooldowns={}
local function isEnemy(model)
    return model and model:IsA("Model") and (model:GetAttribute("EclipseEnemy")==true or CollectionService:HasTag(model,"EclipseEnemy"))
end
remote.OnServerEvent:Connect(function(player)
    local class=player:GetAttribute("EclipseClass")
    if class~="Mage" and class~="Archer" then return end
    local now=os.clock()
    if cooldowns[player] and now-cooldowns[player]< (class=="Mage" and 0.9 or 0.55) then return end
    local character=player.Character
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    local root=character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health<=0 or not root then return end
    cooldowns[player]=now
    local range=class=="Mage" and 75 or 95
    local damage=player:GetAttribute("EclipseBaseDamage") or (class=="Mage" and 35 or 21)
    local origin=root.Position+Vector3.new(0,1.5,0)
    local direction=root.CFrame.LookVector*range
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={character}
    local result=workspace:Raycast(origin,direction,params)
    local hit=false
    if result then
        local current=result.Instance
        while current and current~=workspace do
            if isEnemy(current) then
                local enemyHumanoid=current:FindFirstChildOfClass("Humanoid")
                if enemyHumanoid and enemyHumanoid.Health>0 then
                    enemyHumanoid:TakeDamage(damage)
                    hit=true
                    if enemyHumanoid.Health<=0 and not current:GetAttribute("EclipseRewardClaimed") then
                        current:SetAttribute("EclipseRewardClaimed",true)
                        local data=require(script.Parent:WaitForChild("PlayerDataService"))
                        local quest=require(script.Parent:WaitForChild("QuestService"))
                        local xp=current:GetAttribute("EclipseRewardXP") or 20
                        local gold=current:GetAttribute("EclipseRewardGold") or 10
                        data.AddXP(player,xp); data.AddGold(player,gold); quest.RegisterDefeat(player)
                        feedback:FireClient(player,{kind="Reward",xp=xp,gold=gold})
                    end
                end
                break
            end
            current=current.Parent
        end
    end
    feedback:FireClient(player,{kind="Attack",class=class,hit=hit,damage=hit and damage or 0})
end)
Players.PlayerRemoving:Connect(function(player) cooldowns[player]=nil end)
print("[ECLIPSE] Mage and Archer ranged attacks online.")
