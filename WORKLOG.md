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
- The project is versioned in Git; DEV-002 changes remain reviewable as a focused visual-slice diff.

## DEV-002 visual slice

- Imported the eight supplied temporary component PNGs under `res://art/prototype/dev_002/` without modifying their source pixels.
- Replaced player and NPC polygon markers with four-direction sprite-sheet regions while preserving their existing controllers and interaction contract.
- Rebuilt the zone as a warm tropical home slice with grass variation, an organic dirt road, layered river water/banks, player cottage, crop plot, fence, bridge, tropical trees, and test farmer.
- Established Y-sorted object origins and independent footprint/trunk/bank/fence collision shapes. The bridge is the intentional river crossing.
- Removed all permanent world labels. The F1 overlay is hidden by default and shows zone, position, focus, FPS, and renderer.
- All imported sprites use nearest filtering through their scene-level `texture_filter = 1`; Compatibility rendering and integer window scaling remain active.
- The DEV-002 smoke test passes, and the reviewed gameplay capture is stored at `docs/screenshots/dev-002-visual-slice.png`.

## DEV-003 stabilization

- Replaced all eight supplied prototype PNGs in place. The six environment/building sources are now 256×256; the compressed player and farmer sprite sheets retain their required 1448×1086 atlas dimensions. Godot re-imported them without broken texture paths.
- Retuned the 256 px environment sprites to deliberate 1:1 scale. Character sheets remain at 0.24 scale because their atlas dimensions did not change.
- Player ground collision is a vertical capsule with radius 7 px and height 18 px, offset 3 px toward the feet.
- Each tree uses a trunk/root capsule with radius 17 px and height 30 px; canopy pixels remain non-blocking and participate in Y-sort.
- The garden uses three 146×14 px row colliders with gaps between rows and an unblocked outer margin.
- Fence collision uses separate 232×10 px rail and 10×88 px post/side shapes; the eastern opening remains traversable.
- The river uses two full-depth blockers spanning its 146 px water band. The bridge leaves a 68 px walkable corridor between x=292 and x=360, bounded by two 10×122 px side rails with open north/south endpoints.
- Interaction focus uses a 44 px enter radius and 56 px exit radius. A nearer valid target can replace the current focus; invalid, disabled, freed, or out-of-range targets clear it.
- Interaction messages retain their `InteractionTarget` source and keep a 4-second secondary timeout. They close immediately when the source is invalid/freed, disabled, outside the 56 px exit radius, or replaced by another focus.
- F1 shows focus/session/radius/runtime state. F2 toggles collision visualization for development review.
- Updated the smoke test for structural colliders and owned-message lifecycle. Added a movement/collision test covering two-way bridge crossing, river rejection, bridge side rails, tree cardinal/diagonal blocking, crop rows/margins, fence opening, and house blocking.
- Godot import, DEV-003 smoke test, and collision traversal test pass. Runtime clean and collision-overlay captures were reviewed at `docs/screenshots/dev-003-stabilized-slice.png` and `docs/screenshots/dev-003-collision-review.png`.
- Remaining environment-only warnings: the restricted runner cannot write Godot's user-level logs/editor settings or read the Windows root certificate store. No project parser or runtime failure was introduced.
