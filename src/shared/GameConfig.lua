-- Project ECLIPSE Alpha 0.1
-- Shared settings used by both server and client.

local GameConfig = {}

GameConfig.GameName = "Project ECLIPSE"
GameConfig.Version = "Alpha 0.1"

GameConfig.Player = {
    StartingLevel = 1,
    StartingXP = 0,
    StartingGold = 100,
}

GameConfig.Combat = {
    BaseDamage = 15,
    AttackCooldown = 0.65,
    AttackRange = 8,
}

GameConfig.Dungeon = {
    FirstDungeonName = "Eclipse Training Grounds",
    RecommendedLevel = 1,
}

return GameConfig
