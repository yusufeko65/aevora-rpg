# DEV-001 Work Log

## Baseline inventory

- Project path: `D:\Project\Game RPG\Aevora\aevora`
- Godot: 4.7.2 stable
- Renderer: Compatibility (`gl_compatibility`)
- Pixel/display settings before DEV-001: canvas-items stretch with expand aspect; no explicit viewport size or integer scale mode
- Autoloads: `_mcp_game_helper` from the existing `godot_ai` add-on only
- Existing gameplay scenes/scripts: none
- Existing assets: default `icon.svg` only
- Existing input actions: none defined by the project
- Existing plugins: `godot_ai` and `godot_omni`
- Baseline checks: project imported without parser/runtime failures. Headless execution reported sandbox-only certificate-store and editor-settings write warnings.

## Source review

Reviewed before implementation: DEV-001 handoff, Board Game, Core Story Telling, DLC-001 — The First Village, and ART-001 — Visual Direction. The prototype treats the 32 px grid, sprite proportions, and top-down 3/4 presentation as provisional configuration. Open story, culture, naming, calendar, and future-system decisions are not encoded as final rules.

## Implemented foundation

- Main bootstrap composes one replaceable world zone, the reusable player, and debug HUD.
- Player uses `CharacterBody2D`, collision, a non-smoothed camera, and a reusable nearby-target interaction probe.
- NPC identity is a stable-ID `Resource`; the NPC scene consumes it without map-specific player logic.
- NPC and sign share the same `InteractionTarget` contract.
- Prototype world contains a house, field, village road, NPC, interactable river sign, river edge, and collision boundaries.
- No new global gameplay singleton was introduced.

## Verification

- Godot editor/import pass registers every new global class with no parser errors.
- Headless main-scene startup completes without runtime errors.
- Automated smoke test verifies bootstrap composition, stable zone and NPC IDs, shared NPC/object interaction behavior, and separated world/interaction collision layers.
- Environment-only warning: this sandbox cannot write Godot's user-level log or editor settings and cannot access the Windows root certificate store. These warnings are outside project content.

## Provisional assumptions

- Placeholder geometry and colors are implementation aids, not canonical art.
- The test NPC title and stable ID are prototype-only content.
- Movement speed, 48 px interaction radius, and map dimensions are tuning values.
- The project remains an unversioned working directory; Git status cannot be recorded here.
