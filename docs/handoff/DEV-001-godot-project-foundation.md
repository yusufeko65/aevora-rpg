# DEV-001 — Godot Project Foundation / Codex Handoff

**AEVORA • Prototype 0.1 • Godot 4 • Steam/Windows target**

Status: Draft implementation handoff. Working title AEVORA is temporary. This document must be read together with the current Google Drive design sources before implementation decisions are made.

## 1. Purpose

Build the smallest stable Godot foundation that can grow into AEVORA without locking the project into a one-off prototype architecture. Prototype 0.1 proves movement, camera, collision, interaction, NPC presence, data-driven content hooks, and a small playable village-area slice. It is not the full DLC-001 implementation.

## 2. Source of Truth — Read Before Coding

Codex must study the current project files and the following Google Drive artifacts before changing architecture:

- **Board Game** — master planning board for agreed rules, roadmap, systems, and unresolved decisions.
- **Core Story Telling** — Core Story Bible; world premise, Regression, mystery structure, open-ended life, and DLC/Extension narrative rules.
- **DLC-001 - The First Village** — current opening-world story and village arc specification.
- **ART-001 - Visual Direction** — current visual/pixel/environment recommendations and review state.

If this handoff conflicts with a later explicit decision in those sources, do not silently choose. Preserve the architecture and flag the conflict for review. Items marked Proposed, Review, Open, or TBD are not final world rules.

## 3. Confirmed Game Constraints

- Game identity: Action + Mystery + Science in a fantasy post-regression world with consistent natural laws.
- Progression is capability-based, not traditional character-level gating.
- Combat is real-time in the world; terrain, stamina, injury, equipment, preparation, and numbers can matter.
- NPCs are individuals with skills, traits, needs, progression, schedules, and potential employment.
- World DLC expands place/story; optional Extensions add deeper systems without breaking Core rules.
- The world has no mandatory final ending; settlements and people can continue changing over time.
- Technology requires knowledge + material + tools + infrastructure. Finding an artifact does not automatically unlock reproduction.
- Mystery is fragmented. Ruins, oral history, archives, experiments, and NPC testimony may conflict.

## 4. Current Technical Decisions

- Engine: Godot 4.
- Renderer: Compatibility.
- Primary release target: Windows desktop / Steam.
- Presentation: 2D pixel-art, top-down 3/4 direction.
- ART-001 currently proposes a 32×32 logical tile baseline and approximately 32×48 to 40×56 character sprites. Treat these as provisional constants/configuration, not assumptions scattered through code.
- Nearest-neighbor pixel filtering and integer scaling should be used where practical.
- Implementation recommendation: use GDScript for the prototype unless the existing project already establishes another scripting language. Do not mix languages without a documented reason.

## 5. First Action for Codex + Godot MCP

Before creating or editing files, inspect the current Godot project through the available Godot MCP. Produce a short inventory in the work log: project path, Godot version, renderer, project.godot settings relevant to 2D/pixel rendering, autoloads, existing scenes, scripts, input actions, plugins, assets, and any current errors/warnings.

Do not delete, rename, or reorganize existing user work merely to match this handoff. If the project is effectively empty, apply the foundation below. If it already contains working structure, adapt the foundation to it and document the mapping.

## 6. Prototype 0.1 Scope

Create one small playable test area only. Recommended test composition: Player House → small field → village road → one test NPC → river edge. Placeholder art is acceptable. The purpose is to validate architecture and feel, not to reproduce the full visual concept map.

- Player can move smoothly in the 2D world and cannot pass through collision geometry.
- Camera follows the player without pixel shimmer or unintended smoothing.
- One NPC exists as a reusable NPC scene/entity, not a map-specific script blob.
- One interactable object exists using the same interaction contract as the NPC.
- Interaction input can detect/focus a nearby valid target and trigger a simple response.
- A minimal debug overlay can show player position, focused interactable, current scene/zone, and selected debug state.
- Scene changes/reloads do not require rewriting Player logic.
- Content values used by the prototype are separated from reusable system logic where reasonable.

## 7. Recommended Project Structure

Use the following as a target organization, but adapt it if the current project already has a coherent structure:

```text
res://
  autoload/
  scenes/
    main/
    player/
    npc/
    world/
    buildings/
    interactables/
    ui/
  systems/
    interaction/
    inventory/
    farming/
    combat/
    npc/
    knowledge/
    economy/
    dialogue/
  data/
    items/
    crops/
    npc/
    fauna/
    flora/
    minerals/
    knowledge/
  art/
    characters/
    tilesets/
    environment/
    buildings/
    props/
    ui/
  dlc/
    dlc_001_first_village/
  extensions/
  tests/
```

Folders for systems that are not implemented in Prototype 0.1 may remain absent until needed. Do not create empty architecture merely for appearance.

## 8. Core Scene Responsibilities

### 8.1 Main / Bootstrap

Own startup composition and route into the active world scene. Avoid embedding world-specific gameplay logic in the bootstrap scene.

### 8.2 Player

Reusable CharacterBody2D-based player entity with movement, facing, collision, interaction targeting, and animation hooks. Keep player-domain state separate from map scripts.

### 8.3 World / Zone

Own terrain, static collision, navigation/environment markers, spawn points, zone identity, and local entities. A zone may be replaced later without rewriting global systems.

### 8.4 NPC

Reusable NPC entity with an identity/config reference and extension points for schedule, dialogue, knowledge, employment, relationship, and later aging. Prototype 0.1 only needs identity + interaction response; do not implement full simulation yet.

### 8.5 Interactable Contract

NPCs, doors, signs, containers, tools, artifacts, and future objects should be able to expose a common interaction surface. Avoid hard-coding player logic such as `if target is NPC then...`.

## 9. Data-Driven Rules

- Do not store crop, mineral, NPC, item, knowledge-topic, or world-content definitions as long switch/if chains in gameplay scripts.
- Prefer Resources or another Godot-native structured data approach for authorable definitions; use stable IDs for content that may later be referenced by save files or DLC.
- Keep display name separate from stable ID so localization and renaming do not break saves.
- Do not implement every future property now. Define only what Prototype 0.1 needs, with extension points where a future requirement is already confirmed.

## 10. DLC and Extension Boundary

The project must not assume DLC-001 is the whole game. Core reusable systems belong outside the DLC content folder. DLC-001 may provide maps, NPC definitions, resources, story triggers, local data, and content-specific scripts only when they are truly local.

Optional systems such as Legacy and Empire must be able to deepen the same world/save later. Do not make Core player movement, interaction, NPC identity, or save architecture depend on an optional extension being installed.

## 11. Knowledge & Inquiry — Prepare, Do Not Fully Build Yet

A confirmed design direction is that world knowledge is discoverable rather than automatically revealed. Once the MC learns a topic, that topic can later be asked of NPCs; NPCs may know nothing, know a fragment, repeat a rumor, or provide a profession/culture-specific interpretation. Conflicting testimony can become a puzzle that produces new understanding.

Prototype 0.1 does not need the full Knowledge & Inquiry system. However, avoid dialogue architecture that assumes every NPC has only fixed quest dialogue. NPC interaction should leave room for future topic-based queries and per-NPC knowledge responses.

## 12. DLC-001 World Context to Preserve

The starting region is a rural equatorial/tropical setting centered on ordinary life. Current direction includes rainy and dry seasons, farming fields and rice fields, river and wells as water sources, forest, and an iron/coal mining area. The broader world may later include countries with four seasons. These environmental differences are expected to affect resources, farming, trade, and travel rather than being purely cosmetic.

The village is intended to remain useful after the opening story. Future gameplay may include purchasable empty plots, player buildings, small businesses, NPC employment, worker housing, and gradual settlement growth. Prototype 0.1 only needs to avoid architecture that would prevent these systems later.

## 13. Explicit Out of Scope for Prototype 0.1

- Full village map.
- Final pixel-art asset production.
- Full farming simulation, seasonal calendar, weather simulation, mining, metallurgy, fishing, fauna AI, economy, guilds, property purchase, construction, NPC employment, combat/injury, save migration, Legacy, Empire, or full Knowledge & Inquiry.
- Final NPC names, village name, culture, player family structure, exact first artifact, and other items still marked Open/TBD in design sources.
- Steam SDK integration unless separately requested.

## 14. Acceptance Criteria

- Project opens in Godot 4 with no blocking parser/runtime errors.
- Compatibility renderer remains active unless a specific verified requirement justifies changing it.
- A main scene runs directly from the editor.
- Player movement, collision, camera, focus/interaction, one NPC, and one object work in the prototype area.
- Pixel assets/placeholders render without smoothing artifacts under the chosen viewport/window setup.
- No full-game singleton becomes a dumping ground for unrelated systems.
- No DLC-001-specific content is hard-coded into generic Player or interaction code.
- Codex reports exactly which files/scenes/settings were added or changed and any assumptions that remain provisional.

## 15. Codex Work Rule

Implement in small verified passes. After each meaningful pass, run the project through Godot MCP, inspect errors/warnings, and fix regressions before expanding scope. Prefer a working narrow vertical slice over creating many unfinished systems. Do not implement future systems just because their folders or design concepts exist.

## 16. Definition of Done for DEV-001

DEV-001 is complete when the project has a clean reusable 2D foundation and the Prototype 0.1 acceptance criteria pass. The next handoff should then target one gameplay system at a time—most likely interaction/dialogue + NPC identity, or the first small DLC-001 environment block—based on review of the running prototype.
