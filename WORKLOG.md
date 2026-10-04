# AEVORA Work Log

## DEV-R001 restart inventory (2026-10-03)

DEV-001..004 runtime outputs are superseded by DEV-R001. The entries below remain historical evidence, not current runtime specifications.

- Before reset: `main` at `c1f65b9`, with only the user-supplied DEV-R001 handoff untracked. No unrelated user changes were found.
- Inventoried 122 tracked old runtime/source/import files under scenes, systems, data, tests and art/prototype. Exact paths and preservation decisions: `docs/reports/dev-r001-reset-inventory.md`.
- Preserve Git history, historical handoffs/screenshots, WORKLOG history, add-ons/MCP integrations, icon and valid project settings. Remove/replace only the inventoried obsolete prototype files, in a normal commit.
- Read current ART-001 pixel/world specs and ART-002 asset, animation, source audit and license tabs via read-only Drive/Sheets workflows. Human frame is 64×64, boar 32×32, source terrain tiles 16×16, logical world tiles 32×32.
- Downloaded 33 original vendor files (30 PNGs, 3 TMX) as a deliberately small development subset. Provenance and license limitations are recorded in `art/vendor/craftpix/PROVENANCE.md`; no source edits or remote publication.
- Audit found that Idle Up is **12 timeline steps but only four occupied PNG cells**. TMX explicitly uses columns `[0,0,0,0,0,1,2,2,2,2,2,3]`. Preserve this mapping rather than indexing empty cells or changing the PNG.
- Measured unarmed planted soles at Y=43; provisional anchor is **(32,44)**, independent of the DEV-004 dummy anchor. Run airborne frames end at Y=40–43; that motion is retained without per-frame recentering.

## DEV-R001 delivered baseline

- Replaced the obsolete runtime with native Craftpix player Idle 12 / Walk 6 / Run 8 and four explicit source directions. Exact 150 ms timing, repeated Up-idle TMX columns, stable (32,44) ground anchor, and normalized diagonal movement. Walk/run speeds are exposed at 48/112 px/s.
- Fixed 10×6 player feet rectangle at (0,-1), independent of visual canvas. Tree64/Tree128 retain original variable-size PNGs and small 12×8 / 18×10 trunk footprints. Boar retains 32×32 frames and its different direction order.
- Built a small native 16 px tile ground/80×176 road patch with original tiles, retaining the 32 px logical world unit and 640×360 / 2× integer display.
- Added source-faithful Sword Idle/Walk/Run layer composition and shadow A/B comparison; every timeline step/direction reconstructs the original full source pixels within 1/255 rounding tolerance. Shadow strategy remains Review. Attack/Hurt/Death are lower-priority deferred; Tool is missing source.
- F1 shows timing/state/source row/column/position/FPS; F2 shows canvas, ground/root and actual physics footprints; F3 compares unarmed shadow modes; Tab toggles sword; B switches stationary boar preview. No gameplay systems beyond movement were added.
- Safely removed 118 old tracked files (including 38 PNGs) and replaced four inventoried runtime files. They remain recoverable in Git history. Historical handoffs/screenshots and MCP add-ons remain intact.
- Final checks: source audit PASS; normal-access Godot editor opens cleanly; source/movement/collision/scene suite PASS with 3,543 checks; seven 640×360 gameplay/inspection captures reviewed; git whitespace check PASS. Initial restricted-runner user-log/settings/certificate warnings do not occur during normal-access verification.
- Exact source names, mapping, bbox measurements, preservation/addition/deletion inventory, deferred items, license status and screenshot paths: `docs/reports/dev-r001-baseline-v2.md`.
- License remains Pending; use is development/testing only, no public GitHub push or final commercial clearance. ART sheets were not modified. Stop after this baseline for visual review and the next explicit handoff.
- Commit preflight preserves the supplied handoff's intentional Markdown hard break. A vendor-TMX-only `.gitattributes` exception prevents Git newline normalization; verify staged vendor blobs match the original bytes. Authored changes pass the scoped staged whitespace check.

## DEV-R001.1 delivered refinement (2026-10-04)

- Refined parent `c737e998ae61a28abffe40949feb0e413ff24fea` without reset. Human Idle/Walk/Run mappings, 64×64 canvas, (32,44) pivot, fixed 10×6 feet, speeds and pixel-safe viewport remain unchanged.
- Imported 13 original Drive files: seven Sword Attack PNGs and Exterior.tmx plus five Home PNGs. All 30 original baseline PNG / three TMX hashes remain unchanged; total audited source is 42 PNGs / four TMX. License remains Pending, no public push.
- Native Exterior CSV/GIDs supply a house, yard/fence with traversable gate, main road and grass details, translated by (568,256). Five original trees mix 64/128px sources. Base grass uses measured opaque TMX GID 1014 to match the environment palette without editing art.
- Added Sword Attack 8×150ms in all four directions, non-loop playback with full final-frame hold and one completion signal. Freeze root/facing, ignore spam/Tab while active, return to current Idle/Walk/Run input. Unarmed attack is no-op; movement-specific Sword Walk/Run Attack remains deferred.
- The original Right/step-0 full attack sheet exposes 31 weapon pixels above the body despite the conceptual back-layer order. One source-pixel-derived layer-order override reproduces it; all 32 attack composites, including existing matching source shadow, match the full source within 1/255 blending tolerance. Pivot and vendor pixels are untouched.
- Removed B Boar toggle and stationary timed direction cycling. Boar now waits 1.5–4s, travels at 24 px/s for 1–3s toward an inset target, and derives facing from observed velocity. Bounds Rect2(580,392,144,80), fixed 16×8 feet; environment-only mask, no player combat/collision, navigation or full AI.
- Clean legend includes WASD Move / Direction, Shift Run, Tab Equip / Unequip Sword, LMB / J Attack and F1/F2/F3. F1 adds attack/ambient state, F2 shows all actual footprints, F3 source shadow comparison remains.
- Final verification: source audit PASS; DEV-R001 regression 3,617 checks PASS; DEV-R001.1 14,402 checks / zero failures PASS, including accelerated 120s ambient physics-tick simulation and actual house/fence/gate/roof traversal. Runtime smoke clean; twelve 640×360 native captures visually reviewed. Historical captures preserved.
- Complete mapping/import/file inventory, screenshots, controls, source discrepancy, deferred items and next visual review: `docs/reports/dev-r001-1-visual-playtest-sword-attack.md`. Stop here for review; no combat, inventory or NPC expansion.

## DEV-R001.2 delivered corrective pass (2026-10-04)

- Preserved parent `901e249d0f23371ba222a4c8e66cf43187b77e3c` and the DEV-R001.1 foundation. All 42 existing PNG / four TMX hashes and complete Idle/Walk/Run/standing Attack mappings remain unchanged. Followed revised moving-attack scope/acceptance over the stale introductory deferred line.
- Added physical Arrow keys first in semantic movement actions; retained WASD aliases. Normal legend shows ↑ ↓ ← → and no WASD/B. Physical Arrow movement/facing, mixed aliases and physical J state selection are tested.
- Verified actual Windows game client and root displayed framebuffer 1280×720, logical 640×360, exact 2× integer transform. Five native captures and machine-readable evidence are recorded; no image resizing or asset/character scale changes.
- Replaced fence coordinate heuristics with static GID profiles. Measured original caps as 7px/8px, narrowed only outer caps, aligned sides with source bases, and added composite bottom corners. Former 12px gap is 0px; both-side upper/middle/lower and diagonal seam attempts block, outside caps pass, visible caps block, gate passes both ways.
- Imported 14 unchanged original official-free Craftpix prototype Walk/Run Attack PNGs via verified Drive source. Audit now covers 56 PNGs/four TMX. Prototype permission, source links, hashes and pending final clearance/replacement remain recorded in PROVENANCE with ART-002 → 11 License & Replacement Ledger reference. No remote push or ledger modification.
- Implemented walk_attack 6×150ms and run_attack 8×150ms, one-shot with locked facing/movement/speed class, collision and return to current live input. Every new 56 pose reconstructs full source, including shadow, within 1/255 tolerance. No new pose override; standing Attack Right/step0 override preserved.
- Measured travel 43.19934px / 134.39929px at 48/112px/s. Walk swing reads coherently; Run Attack's long commitment is flagged for future review, not silently retuned. Fence/house/tree blocking does not interrupt completion. No combat, health, inventory or world expansion.
- Verification: DEV-R001 3,701 PASS; DEV-R001.1 14,402/zero failures PASS; DEV-R001.2 726/zero failures PASS (18,829 total). Five 1280×720 captures visually reviewed. Full report: `docs/reports/dev-r001-2-direction-display-fence-collision.md`. Stop for user review / next explicit handoff.

## DEV-R001.3 delivered actor collision correction (2026-10-04)

- Replaced mixed layers with named Player / Environment / Fauna: Player1/mask6, Environment2, Boar4/mask3; migrated house, fence pieces, five trees and boundaries without geometry changes.
- Player and Boar now block direct movement and moving attacks; diagonal contact may slide naturally without penetration. All 40 directional contact cases pass; attack completion remains once, returning to live input.
- Preserved collider sizes/offsets, pivot, source mappings/art, ambient controller and DEV-R001.2 fence tuning. No combat, avoidance, new assets or CONTEXT.md.
- Four regression suites pass: 23,161 checks /zero failures. Three native1280×720 F2/contact/Y-sort captures reviewed. Pre-existing unrelated edits preserved outside the commit.
- Full evidence, issues and lessons: `docs/reports/dev-r001-3-actor-collision.md`. Stop for review; next track requires an explicit choice.

## ART-R001 character asset production R&D (2026-10-04)

- Established isolated64×64 ARTCHAR-R001 pipeline without replacing the DEV-R001.3 runtime Player or changing gameplay/vendor art.
- Built/evaluated Sprite Studio0.3.3 at9de73a6 outside repo; frontend and325Rust tests pass, strict Clippy failure documented. TDSM/Aseprite not available; checklists prepared, no purchase/API fallback.
- Preserved four original masters plus native down Idle4/Walk6. Six other-direction rigs failed anatomy preflight;30frames/complete normalized sheets remain BLOCKED, never filled with dummy copies.
- Added read-only geometry/provenance/source checks and equivalent-scale Godot comparison with explicit source-only/missing labels; root(32,44) unchanged, directional soles+1/+2px and palette drift require review.
- Verification:23,161gameplay checks pass;153validator self-tests,117source structural checks and52comparison checks have zero errors; real complete-asset status staysBLOCKED. Eight native captures reviewed.
- Full report: `docs/reports/art-r001-character-asset-production-rnd.md`. Local commit only; stop for visual/tooling review, no runtime promotion or new states.

## Historical DEV-001..004 records

### DEV-001 Baseline inventory

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
