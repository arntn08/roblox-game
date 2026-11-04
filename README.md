# PROJECT ECLIPSE
## Alpha 0.1 — Anime Action RPG

Mobile-first anime action RPG with classic action combat and R6/R15 character support.

### Current source systems
- Shared game and character configuration
- Session-only Level, XP, and Gold progression
- R6/R15 character initialization
- Server-validated three-hit combo combat
- Touch attack button and keyboard fallback
- Training enemy spawn and basic chase/attack AI
- XP and Gold rewards when an enemy is defeated

### Enemy setup
The current training enemy is spawned automatically by `EnemySpawnService.server.lua`. It uses a simple floating orb placeholder model. Custom character models, animation, and dungeon visuals are planned later.

### Important limitations
- Player data is currently session-only and resets when leaving.
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
6. Testing and publishing
