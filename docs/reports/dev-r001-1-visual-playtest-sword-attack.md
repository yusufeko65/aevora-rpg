# DEV-R001.1 — Visual playtest and sword attack refinement

Implemented 2026-10-04 on parent `c737e998ae61a28abffe40949feb0e413ff24fea`. The implementation commit includes this report, supplied handoff, source evidence, tests and captures; its exact SHA is delivered in the final chat handoff. No remote push. Craftpix license status remains **Pending**, development/testing only.

## Outcome and preserved foundation

The playable scene now contains one native Craftpix house, yard, an open gate within a short fence enclosure, a continuous main path section, five trees using two original sizes, ground/vegetation variation, the player and an ambient wandering Boar. No health, damage, combat events, hitboxes, inventory, NPC/pathfinding, quests or save systems were added.

Human Idle/Walk/Run mappings are semantically identical to DEV-R001. Their direction order, source pixels, frame counts, 150 ms timing and source layer reconstruction remain covered by regression tests. Original baseline vendor hashes remain unchanged: 30 PNGs and 3 TMX files.

- Human canvas: 64×64; source rows Down/Left/Right/Up.
- Player pivot: (32,44), unchanged for locomotion and attack; no pose-dependent recentering.
- Player feet: fixed 10×6 rectangle at (0,-1), unchanged.
- Walk/Run: 48/112 px/s, normalized diagonals and horizontal-facing tie break retained.
- Rendering: Compatibility, nearest native textures, no mipmaps/resizing, 640×360 logical viewport, 1280×720 reference display with integer scale.
- World remains 960×640 with the existing camera limits. New safe player start is (520,326), outside the house footprint.

## Source imports and environment mapping

The Google Drive workflow supplied original bytes, not generated or edited substitutes. Exact canonical source links are in `art/vendor/craftpix/PROVENANCE.md`; PNG geometry/alpha bounds/SHA-256 and TMX metadata/hashes are in `data/source_mapping/craftpix_audit.json`.

13 original additions (12 PNGs, 1 TMX):

```text
main_character/home/
  Exterior.tmx
  exterior.png
  ground_grass_details.png
  house_details.png
  Doors_windows_animation.png
  Smoke_animation.png
main_character/male/
  Sword_attack_with_shadow.png
  Sword_attack_without_shadow.png
  Sword_attack2_sword_back.png
  Sword_attack3_body.png
  Sword_attack4_sword_front.png
  Sword_attack5_head.png
  Sword_attack6_swing.png
```

`Exterior.tmx`, not its copy, is read directly as immutable mapping evidence by the narrow `home_source.gd` reader. Native CSV cell positions, GIDs, first-GID offsets, atlas column counts and horizontal/vertical flip flags are retained. Rendering uses original 16×16 regions with no new cropped image files. Unsupported diagonal/hex transforms and missing selected PNGs stop with an explicit assertion instead of guessing or substituting assets.

The original layout is translated by **(568,256)**, without scaling:

| Source content | Selected original layer IDs |
| --- | --- |
| Ground, spots, road, plates, grass/detail layers | 31,32,30,22,23,44,27,28,29,41,49 |
| House wall, window poses, roof/chimney pose | 50,52,53,51, in source order |
| Fence and open gate | 24; gate GIDs 788 and 789 |

GID **1014**, explicitly present in the TMX Grass layer, supplies the opaque native background grass (atlas region (32,240), 16×16 in `exterior.png`; all 256 pixels are source color #7AAD55). Extending it across the world removes the mismatched rectangular grass backdrop without repainting the source. The main road and yard come from the original Home composition, replacing the isolated DEV-R001 road strip. Historical Road1/Ground_grass source files remain preserved.

The house root is the original tile coordinate (-5,3), translated to **(488,304)**. Its collision is **128×40**, centered at root offset (0,-20): only x=424..552, y=264..304 blocks, not the roof. Source door/window and smoke poses are static; their optional animations/interior interaction are not implemented.

Fence bases use 16×4 horizontal and 6×16 side footprints, Y-sorted per source cell. The original 32px gate is non-blocking. Actual physics tests cover both a blocked rail and passage through the gate.

Five original trees, all at native scale and under Actors Y-sort:

| Node | Source | World root | Trunk footprint |
| --- | --- | --- | --- |
| Tree64 | Tree3.png, 64×64 | (336,360) | 12×8 at (0,-3) |
| Tree128 | Tree1.png, 128×128 | (670,300) | 18×10 at (0,-4) |
| Tree128West | Tree1.png, 128×128 | (295,256) | 18×10 at (0,-4) |
| Tree64South | Tree3.png, 64×64 | (390,440) | 12×8 at (0,-3) |
| Tree64East | Tree3.png, 64×64 | (750,380) | 12×8 at (0,-3) |

Canopies, roof overhang, grass and road are not solid silhouettes. Front/behind tree captures confirm dynamic overlap; a horizontal traversal beneath the roof overhang remains walkable.

## Sword attack, input and completion

`attack_primary` binds **physical J and left mouse button**. Player logic reads the semantic action, not KEY_J. Legend: WASD Move / Direction, Shift Run, Tab Equip / Unequip Sword, LMB / J Attack, F1 Debug Info, F2 Debug Guides, F3 Shadow Compare. **B has no runtime behavior or legend entry.**

All seven attack PNGs are 512×256. `Base_boy.tmx` explicitly confirms four rows of eight 64×64 cells, columns **[0,1,2,3,4,5,6,7]**, eight **150 ms** holds per direction:

| Direction | Physical source row | Duration |
| --- | --- | --- |
| Down | 0 | 1.2 s |
| Left | 1 | 1.2 s |
| Right | 2 | 1.2 s |
| Up | 3 | 1.2 s |

Ordinary source layer order is shadow → sword_back → body → sword_front → head → swing. The existing `Unarmed_Run1_shadow.png` supplies the eight matching shadow cells: all attack layer composites with and without shadow match both original full sheets within 1/255 blending tolerance across all 32 poses.

One vendor inconsistency was measured: **Right, timeline step 0** has 31 weapon pixels hidden by the conceptual back-before-body order, while the original full attack sheet places them above the body. The mapping contains the sole pixel-derived override **body → sword_back → sword_front → head → swing** for that pose. All other poses retain the TMX layer order. `inspect_attack_layers.gd` reproduces the raw inconsistency; the main test verifies all corrected composites. No source PNG was edited or recentered.

Attack metadata adds `loop=false` to the existing Craftpix mapping. SourceSprite holds every frame for its complete duration, including frame 7, then marks finished and emits `animation_finished("attack")` exactly once. It never wraps attack to 0. The player synchronously returns to Idle/Walk/Run from current input. The advance method returns after emission so leftover delta cannot advance the newly selected locomotion state. Locomotion loops are unchanged.

During the 1.2s attack, root movement is suppressed and the existing facing is locked. Extra attacks and Tab are ignored until completion; no queue/combo is created. Unarmed attack is a no-op. Root/collider remain unchanged through Idle → Attack → Idle, and current Walk/Run input resumes after completion.

Sword Walk Attack / Run Attack are **deferred**, not imported/mapped. Moving attacks use the minimum approved policy: stop and play the same eight-frame Sword Attack. No general unarmed attack source is mapped.

## Ambient Boar and debug tools

The former preview node now uses CharacterBody2D with a fixed **16×8** feet rectangle at (0,-2). It waits **1.5–4s**, picks a target inside its inset roam rectangle, walks at **24 px/s** for **1–3s** or until reaching the target, and returns to Idle. A seeded local random generator permits repeatable review; no navigation or other AI system was added.

Roam bounds: **Rect2(580,392,144,80)**, i.e. x=580..724, y=392..472. Target inset is 10px. This field avoids the house, fence and trunk footprints. Facing is derived from actual post-movement velocity, using the baseline deterministic cardinal rule. Stationary Idle preserves facing; there is no independent direction timer. Animation Walk is used only with observed movement. On obstruction it returns to Idle.

Boar layer 4 / mask 2 collides only with environment layer 2 (house/fence/trees have layer 3). The unchanged player layer/mask 1 does not collide with Boar. World bounds remain the player's original collision boundaries; the Boar stays inside its own field.

F1 shows sword equipped/attack active and Boar state/facing in addition to baseline details. F2 reads actual player, Boar, all trunk, house and fence shapes; F3 retains source shadow comparison. No permanent technical panel appears in normal play.

## Verification and captures

Godot 4.7.2 console runner, normal-access verification:

- Source audit PASS: **42 original PNGs / 4 original TMX** hashes and geometry recorded; original DEV-R001 source hashes unchanged.
- `tests/dev_r001_test.gd` PASS: **3,617 checks**. Baseline geometry, source sequences, all direction/locomotion composites, loop timing, root, speeds, diagonal behavior, trunk collision and canopy passage remain covered. Map-dependent assertions were updated for the new road/tree positions only.
- `tests/dev_r001_1_test.gd` PASS: **14,402 checks, zero failures**. Includes exact attack source geometry/TMX timelines, all 32 full-sheet composites, final-frame hold, single completion, large delta, equipped/unarmed input, spam prevention, facing/root lock, locomotion return, controls, native home regions/flip flags, source gate, idle-facing preservation and accelerated 120s ambient physics-tick simulation. Actual physics traversal tests cover house blocking, fence blocking, open gate and roof overhang.
- Main-scene runtime smoke PASS, no parser/runtime errors.
- Authored Git whitespace check PASS. The supplied handoff's intentional Markdown hard break is preserved; vendor TMX is binary-attributed to avoid newline normalization.

12 actual **640×360** nearest/native gameplay captures, visually reviewed. Capture camera is fixed at (488,320), zoom unchanged, so pose/overlap comparisons retain the same scale:

```text
docs/screenshots/dev-r001-1-playtest-area.png
docs/screenshots/dev-r001-1-house-fence.png
docs/screenshots/dev-r001-1-tree-behind.png
docs/screenshots/dev-r001-1-tree-front.png
docs/screenshots/dev-r001-1-sword-idle.png
docs/screenshots/dev-r001-1-sword-attack-down.png
docs/screenshots/dev-r001-1-sword-attack-left.png
docs/screenshots/dev-r001-1-sword-attack-right.png
docs/screenshots/dev-r001-1-sword-attack-up.png
docs/screenshots/dev-r001-1-boar-walk-a.png
docs/screenshots/dev-r001-1-boar-walk-b.png
docs/screenshots/dev-r001-1-debug-footprints.png
```

Boar A/B are observations during real ambient travel, not a stationary Walk preview. Static captures satisfy this handoff; no video was produced. Historical DEV-R001 images remain untouched.

## Files, gaps and next review

Changed runtime/data: `project.godot`, `data/source_mapping/craftpix.json`, `craftpix_audit.json`, `systems/animation/source_sprite.gd`, `scenes/player/player.gd`, `scenes/fauna/boar_preview.gd/.tscn`, `scenes/world/test_world.gd/.tscn`, `scenes/dev/debug_overlay.gd`, `footprint_guides.gd`.

Added `scenes/world/home_source.gd`, `home_tiles.gd`, `tests/dev_r001_1_test.gd`, `capture_dev_r001_1.gd`, `inspect_attack_layers.gd`, `inspect_home_ground.gd`; updated `tests/audit_craftpix_source.gd` and `dev_r001_test.gd`. Added the source files listed above with native Godot import metadata, the supplied handoff, this report, twelve captures/import metadata, and the WORKLOG/provenance updates. Existing engine/add-ons and historical project evidence are preserved.

No required selected dependency is missing. Full `Exterior.tmx` also references **bird_jump_animation.png, bird_fly_animation.png, Trees_animation.png and cat_animation.png**; these unselected layers/objects were deliberately not imported or rendered. They are available in Drive, not claimed to be missing from the source pack. The original TMX subset is not a complete redistributable vendor pack. The measured Right/step-0 layer discrepancy is resolved against the original full sheet and explicitly recorded above.

Next step: visual review of house/road/player/tree scale, source attack pacing, Y-sort overlap and ambient Boar motion. Keep pivot/collider/speeds provisional and license Pending. Do not proceed automatically to combat, inventory or NPC systems, and do not push vendor assets publicly without license verification.
