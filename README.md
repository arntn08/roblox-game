# PROJECT ECLIPSE
## Alpha 0.1 — Anime Action RPG

Project ECLIPSE is a mobile-first anime action RPG inspired by classic dungeon-based action games.

### Current design
- Character support: R6 and R15
- Combat direction: classic action combat
- Target platform: mobile first
- First playable area: Eclipse Training Grounds

### Repository structure

```text
roblox-game/
├── default.project.json
├── README.md
└── src/
    ├── client/
    │   └── ClientBootstrap.client.lua
    ├── server/
    │   └── GameBootstrap.server.lua
    └── shared/
        └── GameConfig.lua
```

### Development notes
- Server scripts own important gameplay decisions.
- Shared modules hold settings used by both server and client.
- Client scripts will handle player-facing controls and interface.
- Mobile controls will be designed for touch input.
- Both R6 and R15 character rigs are part of the target design.

### Roblox Studio requirement
Roblox Studio is required to build, run, and test the Roblox experience. This repository stores the project source files. Rojo can sync these files into Roblox Studio on a supported desktop computer.

### Alpha 0.1 development sequence
1. Project structure and initialization
2. Character setup and spawning
3. Combat system
4. Training dungeon and enemies
5. Mobile controls and interface
6. Testing and balancing
