-- Playable class definitions. Server applies the selected class stats.
local ClassConfig = {}
ClassConfig.Classes = {
    Swordsman = {DisplayName="SWORDSMAN", Weapon="Eclipse Blade", Damage=20, MaxHealth=130, Defense=10, Color=Color3.fromRGB(70,170,255)},
    Mage = {DisplayName="MAGE", Weapon="Astral Staff", Damage=25, MaxHealth=90, Defense=4, Color=Color3.fromRGB(185,110,255)},
    Archer = {DisplayName="ARCHER", Weapon="Moon Bow", Damage=18, MaxHealth=105, Defense=6, Color=Color3.fromRGB(100,230,165)},
}
ClassConfig.DefaultClass = "Swordsman"
return ClassConfig
