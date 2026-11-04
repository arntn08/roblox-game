-- Project ECLIPSE Alpha 0.1
-- Character and progression settings.

local CharacterConfig = {}

CharacterConfig.Defaults = {
    Level = 1,
    XP = 0,
    Gold = 100,
    MaxHealth = 100,
    BaseDamage = 15,
    Defense = 5,
}

CharacterConfig.Progression = {
    BaseXPToNextLevel = 100,
    XPPerLevel = 50,
}

function CharacterConfig.GetXPToNextLevel(level)
    level = math.max(1, tonumber(level) or 1)
    return CharacterConfig.Progression.BaseXPToNextLevel
        + ((level - 1) * CharacterConfig.Progression.XPPerLevel)
end

return CharacterConfig
