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

## DEV-004 character visual validation

- Reviewed DEV-001 through DEV-004, ART-001 Pixel Art Spec, ART-002 Asset Registry/animation/QA/direction tabs, and ARTGEN-001. ARTGEN-001's fixed camera, identity, center, ground relationship, gait, and hard-pixel invariants were preserved; its 48–52 px body, Y=56 anchor, fixed 6×4 layout, fixed row order, and global palette-count assumptions were not promoted.
- ART-002 currently records `CHAR-001` as Missing. To avoid inventing canonical player art, DEV-004 uses `prototype_validation_001`, a deterministic validation dummy that is explicitly marked `prototype_validation` in its manifest.
- Added authoritative JSON schema-version-1 data at `data/character_visual/prototype_validation_001.json`. It declares a 64×64 canvas, provisional anchor (32,48), four canonical directions, semantic layers, explicit direction rows, per-state files, frame counts, durations, and loop behavior.
- Validation states are Idle 4, Walk 6, Run 8, Attack 5, Hurt 3, Dead 6, and Tool 7 frames. Attack and Tool deliberately avoid six frames to prove runtime playback is not coupled to one universal frame count. Attack timing is phase-variable.
- The dummy atlas uses a deliberately non-default row order (`up`, `right`, `down`, `left`) so the scene and tests prove that row mapping comes from manifest metadata rather than code assumptions.
- Added reusable `CharacterVisual` composition with Shadow, BackLayers, Body/Hair/Outfit, FrontLayers, and VFX. All ordinary layers receive the same state, direction, region, frame index, duration, anchor, and scale. The test equipment moves behind the body when facing up and in front for the other test directions.
- `visible_on_character` remains separate from gameplay ownership: the scene can suppress equipment visuals without changing the manifest/equipment identity.
- Added a dedicated validation scene at `scenes/dev/character_visual_validation.tscn`. Controls: 1–7 state, WASD/arrows direction, Q/E equipment hidden/visible, F1 anchor guides, F2 canvas bounds, F3 terrain contrast, and F4 0.25× playback.
- The scene displays a 4× inspection view plus 1× 64 px-canvas and exact 0.5× 32 px-canvas previews on representative light/dark terrain. The prototype down-idle body/hair/outfit union occupies 17×33 opaque pixels inside its fixed 64×64 frame.
- Provisional anchor result: (32,48). The dummy's planted soles terminate at Y=47, placing the world anchor one pixel below the visible feet. This keeps the node/root fixed while leaving room above and below for motion and equipment; it is a validation result, not a permanent VIS lock.
- Runtime-scale finding: the 1× 64 px canvas produces the intended roughly 32 px-class body and retains face/material separation. Exact 0.5× downscale remains crisp but reduces the dummy to roughly 9×17 visible pixels and loses important detail. Recommendation for VIS-001 review: distinguish “32 px-class body readability” from “32 px canvas output”; keep 1× as the current character default and treat 0.5× as an optional tiny presentation until canonical art QA.
- PNG validation inspects actual decoded pixels: PNG load, atlas dimensions, alpha presence, transparent background, hard 0/255 alpha, clear cell borders, direction coverage, frame/duration counts, and anchor bounds. Intentional invalid fixtures prove wrong dimensions and opaque backgrounds are rejected.
- Automated tests: `tests/dev_004_manifest_validation_test.gd` and `tests/dev_004_character_visual_test.gd`. Both pass, as do the unchanged DEV-003 smoke and traversal tests. No parser/runtime regression was introduced.
- Visual QA capture: `docs/screenshots/dev-004-character-visual-validation.png`. The fixed canvas, X=32 center line, Y=48 ground anchor, layer alignment, light/dark contrast, and two runtime scales were reviewed. The dummy is structurally useful but deliberately not an anatomy/art-quality approval.
- Launch the harness with: `Godot_v4.7.2-stable_win64.exe --path <project> --editor res://scenes/dev/character_visual_validation.tscn`, or open that scene and press F6 in the editor.
