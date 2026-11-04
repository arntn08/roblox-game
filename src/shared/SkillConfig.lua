-- Project ECLIPSE Alpha 0.1
-- Skill definitions are shared for display; the server validates all cooldowns and damage.

local SkillConfig = {}

SkillConfig.Skills = {
    EnergySlash = {
        DisplayName = "ENERGY SLASH",
        Key = "Z",
        Cooldown = 5,
        DamageMultiplier = 2,
        Shape = "Forward",
        Range = 11,
        Radius = 5,
        Color = Color3.fromRGB(55, 190, 255),
    },
    EclipseBurst = {
        DisplayName = "ECLIPSE BURST",
        Key = "X",
        Cooldown = 12,
        DamageMultiplier = 2.8,
        Shape = "Area",
        Range = 0,
        Radius = 13,
        Color = Color3.fromRGB(130, 75, 255),
    },
    ShadowNova = {
        DisplayName = "SHADOW NOVA",
        Key = "C",
        Cooldown = 30,
        DamageMultiplier = 5,
        Shape = "Area",
        Range = 0,
        Radius = 20,
        Color = Color3.fromRGB(40, 225, 255),
    },
}

return SkillConfig
