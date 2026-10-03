# DEV-R001 Restart Baseline v2 — delivery report

Implemented 2026-10-03 on `main`, starting from `c1f65b9`. The final normal commit SHA is reported in the Codex delivery message. No history rewrite, force push or remote push was performed.

## Delivered baseline

Fresh CharacterBody2D player using original Craftpix 64×64 frames at native 1×; Idle 12 / Walk 6 / Run 8 in four directions; original 150 ms steps; a small source-tiled road/ground area; stationary Boar Idle/Walk preview; native 64×64 and 128×128 tree canvases; independent foot/trunk physics; simple source-layer sword locomotion and two shadow modes. No NPC, dialogue, farming, inventory, combat, quest, physiology or clock system remains in the runtime.

The runtime has one small source player and explicit data for these two tested asset families. It does not reuse the DEV-004 generic manifest/schema framework or generated dummy.

Read-only Google Drive/Sheets review grounded the implementation in current ART-001 and ART-002, particularly the locked human size and different direction orders. Neither Sheet was edited.

## Reset and preservation

- Inventoried 122 old tracked paths **before** deletion. 118 obsolete files were removed; four were replaced: `scenes/main/main.tscn`, `scenes/player/player.gd`, its `.uid`, and `player.tscn`. The deletion set includes 38 prototype PNGs and old NPC/interaction/character-visual systems, validation harnesses, scenes, data and tests.
- Exact obsolete paths and decisions: [reset inventory](dev-r001-reset-inventory.md). All original content remains recoverable from Git `c1f65b9`; no unrelated work was discarded.
- Preserved `.git` and history, `addons/` for MCP/editor integration, icon, metadata, valid Compatibility/viewport settings, historical handoffs and all historical DEV-002..004 screenshots. Existing WORKLOG entries remain under a clear supersession notice. Added a narrowly scoped `.gitattributes` exception so Git retains the original vendor TMX line endings/bytes rather than normalizing them.
- Added files are listed at the end of this report, including import metadata and Godot-generated script UIDs.

## Original PNGs used

30 byte-identical PNGs plus three TMX evidence files. Exact Drive URLs and project paths: [vendor provenance](../../art/vendor/craftpix/PROVENANCE.md). Original SHA-256 hashes, geometry and every occupied/empty physical-frame bbox: [decoded audit](../../data/source_mapping/craftpix_audit.json).

| Role | Original PNG names |
| --- | --- |
| Unarmed full A | Unarmed_Idle_with_shadow.png; Unarmed_Walk_with_shadow.png; Unarmed_Run_with_shadow.png |
| Unarmed body B | Unarmed_Idle_without_shadow.png; Unarmed_Walk_without_shadow.png; Unarmed_Run_without_shadow.png |
| Separate original shadow | Unarmed_Idle1_shadow.png; Unarmed_Walk1_shadow.png; Unarmed_Run1_shadow.png |
| Sword Idle parts | Sword_Idle2_sword_back.png; Sword_Idle3_body.png; Sword_Idle4_sword_front.png; Sword_Idle5_head.png |
| Sword Walk parts | Sword_Walk2_sword_back.png; Sword_Walk3_body.png; Sword_Walk4_sword_front.png; Sword_Walk5_head.png |
| Sword Run parts | Sword_Run2_sword_back.png; Sword_Run3_body.png; Sword_Run5_sword_front.png; Sword_Run4_head.png |
| Sword comparison evidence | Sword_Idle_without_shadow.png; Sword_Walk_without_shadow.png; Sword_Run_without_shadow.png |
| Boar | Boar_Idle_with_shadow.png; Boar_Walk_with_shadow.png |
| Flora | Tree3.png (64×64); Tree1.png (128×128), original base/no-shadow variants |
| Terrain | Ground_grass.png (272×496); Road1_grass.png (240×416) |

TMX evidence: `Base_boy.tmx`, `Animals.tmx`, `Roads.tmx`. These are partial-pack evidence only: their unrelated images are intentionally not all downloaded. No Tiled importer dependency was added.

## Exact playback mapping

Authoritative tested data: [craftpix.json](../../data/source_mapping/craftpix.json).

- Human logical cells: 64×64. Source rows Down=0, Left=1, Right=2, Up=3. No direction mirroring or PNG rearrangement.
- Human Idle: 768×256, 12 timeline steps. Down/Left/Right use columns 0..11. **Up uses [0,0,0,0,0,1,2,2,2,2,2,3]**, copied from the TMX: only four up-idle physical cells are populated. This applies identically to the full body and all sword parts. Empty trailing cells are never displayed.
- Human Walk: 384×256, six steps, columns 0..5 in every direction. Run: 512×256, eight steps, columns 0..7 in every direction.
- All implemented steps are exactly 150 ms (6.667 animation steps/s). Full cycles: Idle 1.8 s, Walk 0.9 s, Run 1.2 s. All loop; accumulated elapsed time preserves excess delta.
- Sword layer order is source shadow → sword_back → body → sword_front → head, using the same timeline, source column and anchor. Run's filename numbering differs from visual order: front=5, head=4. Pixel composition was tested against the original no-shadow full sword sheet for every timeline step and direction.
- Shadow A uses the original unarmed with-shadow sheet. Shadow B composes the original state shadow and no-shadow body. Both reproduce the same source pixels to at most 1/255 rounding tolerance, with zero differing pixels beyond that tolerance in all checked frames. Sword uses separate source shadow in its layer test. Shadow choice remains **Review**, not a final art rule.
- Boar: 32×32 cells, Down=0, Up=1, Left=2, Right=3; Idle 128×128 / four steps; Walk 192×128 / six steps; 150 ms each. A stationary preview cycles directions every 3.6 s; B toggles Idle/Walk, without AI or collision.
- Terrain tiles remain native 16×16; logical world units remain 32 px=1 m. Ground uses verified fully opaque atlas cell (2,2). Road uses five source columns beginning at (0,5) and source-row sequence [0,1,2,2,2,2,2,2,2,3,4] to create a short native 80×176 patch. No full vendor map or 16→32 source resampling.

## Measured anchor and physics

Unarmed measurements exclude source shadow and ignore empty physical cells. Bbox below is the **union of all actual poses**, not a recentering rectangle; per-frame bboxes remain in the audit. Origin and dimensions are source-cell pixels.

| State | Facing | Union bbox: origin / W×H | Last opaque foot Y range | Visible bbox center X range |
| --- | --- | --- | --- | --- |
| Idle | Down | (25,22) 13×22 | 43–43 | 31.5–31.5 |
| Idle | Left | (26,22) 12×22 | 43–43 | 32–32 |
| Idle | Right | (26,22) 12×22 | 43–43 | 32–32 |
| Idle | Up | (25,22) 14×22 | 43–43 | 31.5–32.5 |
| Walk | Down | (25,21) 14×23 | 43–43 | 31.5–32.5 |
| Walk | Left | (26,20) 12×24 | 43–43 | 32–32 |
| Walk | Right | (26,20) 12×24 | 43–43 | 32–32 |
| Walk | Up | (25,20) 14×24 | 43–43 | 31.5–32.5 |
| Run | Down | (23,20) 17×24 | 40–43 | 30.5–32.5 |
| Run | Left | (24,19) 15×25 | 41–43 | 31–32 |
| Run | Right | (25,19) 15×25 | 41–43 | 32–33 |
| Run | Up | (23,20) 17×24 | 40–43 | 30.5–32.5 |

- Stable provisional ground anchor **(32,44)**: planted soles end at Y=43, so world root lies one pixel below them. Run's airborne phase remains at Y=40–43. Source motion/center shifts are preserved, never compensated by root teleportation or per-frame recentering. Shadow extends to Y=46.
- Player collider: fixed **10×6 rectangle**, local center (0,-1); independent from 64×64 visual canvas. Speeds exposed as **walk=48 px/s (1.5 m/s), run=112 px/s (3.5 m/s)**, provisional ART-001 review values. Movement uses normalized real physics delta, not animation FPS.
- Diagonal facing: larger absolute axis wins; exact ties prefer horizontal. Idle holds previous facing. No last-key race or direction mirroring.
- Tree3 visible bbox (13,8), 39×43 inside its 64×64 canvas; anchor (32,51), 12×8 trunk collider centered (0,-3).
- Tree1 visible bbox (33,25), 62×74 inside its 128×128 canvas; anchor (64,99), 18×10 trunk collider centered (0,-4).
- Boar's anchor (16,28) follows its source shadow bottom at Y=27. Idle Down's visible+shadow occupancy is 21×22–23; side-facing occupancy is about 27×21–22. It is wider than the 12–17 px human silhouette and similar in rendered height, despite a smaller canvas. This is a source-scale observation, not an approved species scale.

## Rendering and visual observations

Godot 4.7.2 Compatibility renderer retained. Logical viewport 640×360, default window 1280×720 (2×), integer stretch; screenshots intentionally use native 640×360 gameplay pixels.

All pixel nodes inherit nearest filtering. PNG imports are lossless, no mipmaps, no size limiting/resampling; default alpha-border fixing remains enabled. 2D transform pixel snapping is enabled; camera smoothing is disabled. Physics coordinates remain continuous. No arbitrary fractional sprite scale.

All twelve unarmed state/direction combinations were reviewed on the native-size board, with actual gameplay captures for Idle/Walk/Run. No frame bleeding or blur observed. The 64 px canvas is mostly transparent: human body height is 22–25 px. Source boar and tree silhouettes remain readable without increasing/decreasing source scale. The 128 tree silhouette is roughly 3.4× human idle height and the 64 tree about 2×. The road canvas is 80 px (2.5 logical tiles) wide; artwork occupies less at rounded ends. Camera framing intentionally shows only a sparse technical slice, not a finished village.

F2 draws the real foot/trunk collider geometry in pink above terrain, separately from yellow sprite frame and cyan ground line; guides do not change positions. Final rendering, scale, collision and shadow choices remain review items.

## Tests and evidence

- `tests/audit_craftpix_source.gd`: PASS; 30 PNGs decoded and measured, original hashes recorded, TMX subtile animation sequences reduced only after checking their logical-column/timing agreement.
- Godot editor initialization on the new main scene: PASS, exit 0, no project parser/runtime errors.
- `tests/dev_r001_test.gd`: **PASS, 3,543 checks**, exit 0. Independent source geometry, native import settings/hashes, exact TMX mapping/timing, all directions/frames including repeated Idle Up cells, shadow/sword pixel reconstruction, delta carry/loops, root and collider stability, debug toggles, normalized diagonal motion, 48/112 px/s movement, trunk blocking/canopy traversal, main scene smoke.
- `tests/capture_dev_r001.gd`: PASS, seven real rendered 640×360 captures; reviewed individually. Renderer observed: OpenGL 3.3 Compatibility, Intel UHD Graphics 620. These short captures are not a performance benchmark.
- Whitespace check: PASS for authored changes. The user-supplied handoff's intentional two-space Markdown hard break on its Status line is retained and excluded from the staged code whitespace check. Original vendor TMX is treated as binary mapping evidence in Git to preserve its complete CRLF bytes without whitespace normalization. All 33 staged vendor blobs were checked against the original on-disk bytes.
- Restricted runner initially reported inaccessible user log/editor settings and Windows certificate store. The normal-access editor/test/render verification completed without these sandbox warnings.

| Capture | Evidence |
| --- | --- |
| [dev-r001-idle-down.png](../screenshots/dev-r001-idle-down.png) | Native player, boar, 64/128 trees, road |
| [dev-r001-walk-left.png](../screenshots/dev-r001-walk-left.png) | Side walk |
| [dev-r001-run-right.png](../screenshots/dev-r001-run-right.png) | Run pose |
| [dev-r001-debug-feet.png](../screenshots/dev-r001-debug-feet.png) | Frame, root, ground line, real player/tree collision, timing |
| [dev-r001-shadow-b.png](../screenshots/dev-r001-shadow-b.png) | Separate original source shadow |
| [dev-r001-sword-layers.png](../screenshots/dev-r001-sword-layers.png) | Synchronized sword locomotion layers |
| [dev-r001-all-directions.png](../screenshots/dev-r001-all-directions.png) | Twelve native-size unarmed state/direction combinations |

## Controls and reproduction

Open `scenes/main/main.tscn` and run the project. WASD movement; Shift run; Tab unarmed/sword; F1 info; F2 canvas/root/physics guides; F3 unarmed shadow A/B; B stationary boar Idle/Walk.

From project directory, use the installed Godot executable with `--headless --path . --script res://tests/dev_r001_test.gd`. Generate visual evidence with `--path . --resolution 640x360 --script res://tests/capture_dev_r001.gd`. Recompute source audit with `--headless --path . --script res://tests/audit_craftpix_source.gd`.

## Gaps and next review (no automatic continuation)

- Tool source is missing/deferred; unarmed attack is not supplied. No AI replacement art.
- Sword attack/swing, Hurt and Death are lower-priority **deferred**, not missing claims. Their source counts (attack 8, hurt 5, death 7 with final 300 ms) were read but no untested runtime state is advertised.
- Farm Supplies/Plants packed-atlas extraction remains unmapped/deferred. Home and incomplete copied-Exterior references are not used. Unrelated source TMX references are intentionally excluded; all chosen runtime PNGs are present and validated.
- **License remains Pending** in ART-002. Local development/testing is authorized by the handoff; no final commercial approval or public raw-source redistribution is claimed. Vendor provenance must be checked before any public push/distribution. No GitHub publication was performed.
- Recommended next handoff: review these native-scale captures and movement first; explicitly approve/tune human pivot, collision, walk/run feel, road/tree/boar scale and shadow strategy. Then choose one next focus (equipment/animation, terrain, fauna or home). Do not accumulate features automatically.

## Added paths

- `art/vendor/craftpix/PROVENANCE.md`
- `art/vendor/craftpix/fauna/hunt_animal/Animals.tmx`
- `art/vendor/craftpix/fauna/hunt_animal/Boar_Idle_with_shadow.png`
- `art/vendor/craftpix/fauna/hunt_animal/Boar_Idle_with_shadow.png.import`
- `art/vendor/craftpix/fauna/hunt_animal/Boar_Walk_with_shadow.png`
- `art/vendor/craftpix/fauna/hunt_animal/Boar_Walk_with_shadow.png.import`
- `art/vendor/craftpix/flora/tree/Tree1.png`
- `art/vendor/craftpix/flora/tree/Tree1.png.import`
- `art/vendor/craftpix/flora/tree/Tree3.png`
- `art/vendor/craftpix/flora/tree/Tree3.png.import`
- `art/vendor/craftpix/main_character/male/Base_boy.tmx`
- `art/vendor/craftpix/main_character/male/Sword_Idle2_sword_back.png`
- `art/vendor/craftpix/main_character/male/Sword_Idle2_sword_back.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Idle3_body.png`
- `art/vendor/craftpix/main_character/male/Sword_Idle3_body.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Idle4_sword_front.png`
- `art/vendor/craftpix/main_character/male/Sword_Idle4_sword_front.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Idle5_head.png`
- `art/vendor/craftpix/main_character/male/Sword_Idle5_head.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Idle_without_shadow.png`
- `art/vendor/craftpix/main_character/male/Sword_Idle_without_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Run2_sword_back.png`
- `art/vendor/craftpix/main_character/male/Sword_Run2_sword_back.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Run3_body.png`
- `art/vendor/craftpix/main_character/male/Sword_Run3_body.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Run4_head.png`
- `art/vendor/craftpix/main_character/male/Sword_Run4_head.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Run5_sword_front.png`
- `art/vendor/craftpix/main_character/male/Sword_Run5_sword_front.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Run_without_shadow.png`
- `art/vendor/craftpix/main_character/male/Sword_Run_without_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Walk2_sword_back.png`
- `art/vendor/craftpix/main_character/male/Sword_Walk2_sword_back.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Walk3_body.png`
- `art/vendor/craftpix/main_character/male/Sword_Walk3_body.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Walk4_sword_front.png`
- `art/vendor/craftpix/main_character/male/Sword_Walk4_sword_front.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Walk5_head.png`
- `art/vendor/craftpix/main_character/male/Sword_Walk5_head.png.import`
- `art/vendor/craftpix/main_character/male/Sword_Walk_without_shadow.png`
- `art/vendor/craftpix/main_character/male/Sword_Walk_without_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Idle1_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Idle1_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Idle_with_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Idle_with_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Idle_without_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Idle_without_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Run1_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Run1_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Run_with_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Run_with_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Run_without_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Run_without_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Walk1_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Walk1_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Walk_with_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Walk_with_shadow.png.import`
- `art/vendor/craftpix/main_character/male/Unarmed_Walk_without_shadow.png`
- `art/vendor/craftpix/main_character/male/Unarmed_Walk_without_shadow.png.import`
- `art/vendor/craftpix/tile/path_and_road/Ground_grass.png`
- `art/vendor/craftpix/tile/path_and_road/Ground_grass.png.import`
- `art/vendor/craftpix/tile/path_and_road/Road1_grass.png`
- `art/vendor/craftpix/tile/path_and_road/Road1_grass.png.import`
- `art/vendor/craftpix/tile/path_and_road/Roads.tmx`
- `data/source_mapping/craftpix.json`
- `data/source_mapping/craftpix_audit.json`
- `docs/handoff/DEV-R001-restart-baseline-v2-craftpix-asset-first-foundation.md`
- `docs/reports/dev-r001-reset-inventory.md`
- `docs/screenshots/dev-r001-all-directions.png`
- `docs/screenshots/dev-r001-all-directions.png.import`
- `docs/screenshots/dev-r001-debug-feet.png`
- `docs/screenshots/dev-r001-debug-feet.png.import`
- `docs/screenshots/dev-r001-idle-down.png`
- `docs/screenshots/dev-r001-idle-down.png.import`
- `docs/screenshots/dev-r001-run-right.png`
- `docs/screenshots/dev-r001-run-right.png.import`
- `docs/screenshots/dev-r001-shadow-b.png`
- `docs/screenshots/dev-r001-shadow-b.png.import`
- `docs/screenshots/dev-r001-sword-layers.png`
- `docs/screenshots/dev-r001-sword-layers.png.import`
- `docs/screenshots/dev-r001-walk-left.png`
- `docs/screenshots/dev-r001-walk-left.png.import`
- `scenes/dev/debug_overlay.gd`
- `scenes/dev/debug_overlay.gd.uid`
- `scenes/dev/footprint_guides.gd`
- `scenes/dev/footprint_guides.gd.uid`
- `scenes/dev/source_review.gd`
- `scenes/dev/source_review.gd.uid`
- `scenes/fauna/boar_preview.gd`
- `scenes/fauna/boar_preview.gd.uid`
- `scenes/fauna/boar_preview.tscn`
- `scenes/world/test_world.gd`
- `scenes/world/test_world.gd.uid`
- `scenes/world/test_world.tscn`
- `systems/animation/source_sprite.gd`
- `systems/animation/source_sprite.gd.uid`
- `tests/audit_craftpix_source.gd`
- `tests/audit_craftpix_source.gd.uid`
- `tests/capture_dev_r001.gd`
- `tests/capture_dev_r001.gd.uid`
- `tests/dev_r001_test.gd`
- `tests/dev_r001_test.gd.uid`
- `docs/reports/dev-r001-baseline-v2.md` (this report).
