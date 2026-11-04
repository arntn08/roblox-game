# PROJECT ECLIPSE
## Alpha 0.1 — Anime Action RPG

Mobile-first anime action RPG with classic action combat and R6/R15 character support.

### Current source systems
- Shared game and character configuration
- Session-only Level, XP, and Gold progression
- R6/R15 character initialization
- Server-validated three-hit combo combat
- Touch attack button and keyboard fallback
- Three server-validated character skills: Energy Slash, Eclipse Burst, and Shadow Nova
- Skill cooldown validation and area/forward hit detection
- Mobile Level, XP, and Gold HUD
- Three selectable classes: Swordsman, Mage, and Archer
- Starter weapon stat assignments and generated R6/R15 weapon visuals: Eclipse Blade, Astral Staff, and Moon Bow
- Mage bolt and Archer arrow-style server ray attacks with visible traces
- Starter inventory panel with server-validated class-locked equipment
- Portal-based transition to a second prototype dungeon stage
- Eclipse Guardian boss health bar
- DataStore-backed Level, XP, and Gold saving with safe fallback
- Three enemy archetypes: Eclipse Wisp, Void Stalker, and Abyss Brute
- Eclipse Guardian dungeon boss with proximity pulse attack and respawn
- Repeatable defeat quest: defeat five enemies for bonus XP and Gold
- Training enemy spawn and basic chase/attack AI
- Procedurally generated Eclipse Training Grounds arena, portal, pillars, lighting, and player spawn
- XP and Gold rewards when an enemy is defeated

### Enemy setup
The current training enemy is spawned automatically by `EnemySpawnService.server.lua`. It uses a simple floating orb placeholder model. Custom character models, animation, and dungeon visuals are planned later.

### Important limitations
- Player progression uses DataStore `ProjectECLIPSE_PlayerData_v1`; saving requires the experience to be published and Studio API access enabled for Studio tests. If DataStore requests fail, the game falls back to session defaults and warns in Output.
- Class choice and equipment are currently session-only; only Level, XP, and Gold are persisted.
- This repository contains Roblox source files, not a published Roblox place.
- Roblox Studio is required to sync, build, and test the game on a supported Windows or macOS computer.
- The scripts have been committed but have not yet been runtime-tested in Roblox Studio.

### Project layout
- `src/shared`: shared configuration
- `src/server`: server gameplay systems
- `src/client`: player controls and UI
- `default.project.json`: Rojo mapping

### Roadmap
1. Project structure
2. Character and progression foundation
3. Basic combat
4. Training enemy and AI
5. Dungeon map and mobile HUD polish
6. Character skills and progression HUD
7. Classes, starter weapon stats, enemy roster, boss, and repeatable quest foundation
8. Ranged class combat, starter inventory, weapon visuals, stage transition, boss HUD, and progression saving
9. Custom character/monster rigs, polished weapon meshes, animations, and testing
10. Publishing
