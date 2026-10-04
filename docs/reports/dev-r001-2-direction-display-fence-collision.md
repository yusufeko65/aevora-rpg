# DEV-R001.2 — Direction, native display, fence and moving sword attacks

Delivered 2026-10-04 against parent `901e249d0f23371ba222a4c8e66cf43187b77e3c`, preserving DEV-R001.1. Revised §8, scope and acceptance criteria supersede the stale “moving attacks deferred” sentence in §1. No new combat/world systems.

## 1. Commit and preserved baseline

This report belongs to the implementation commit; exact SHA is supplied in the final completion message. Parent is recorded above. No push.

Verified unchanged against parent: all 42 prior PNG hashes, four TMX hashes, complete Human Idle/Walk/Run/standing Attack mappings, player scene/feet collider, SourceSprite playback code, boar code/scene, tree geometry, home sprite placement and logical display settings. No PNG/TMX was edited.

## 2–4. Arrow input, aliases and legend

| Semantic action | Primary physical key | Godot key code | Secondary alias retained |
| --- | --- | ---: | --- |
| move_up | ↑ | 4194320 | W |
| move_down | ↓ | 4194322 | S |
| move_left | ← | 4194319 | A |
| move_right | → | 4194321 | D |

Each Arrow event is first in its existing action. Player still reads `Input.get_vector("move_left", "move_right", "move_up", "move_down")`; no direct Arrow checks were added to gameplay movement. Existing horizontal-priority diagonal facing is preserved.

Tests inject physical Arrow events, verify press/release and actual movement/facing, plus normalized mixed Arrow/WASD input without cross-release interference. Physical J tests verify selection of all three attack families.

Normal legend shows `↑ ↓ ← →  Move / Direction`, Shift Run, Tab Equip/Unequip Sword, LMB/J Attack and F1/F2/F3. WASD is omitted; B stays absent. Debug controls pass regression tests.

## 5–6. Actual native 1280×720 display

Logical simulation remains **640×360**, Compatibility, nearest filtering, canvas_items and integer scaling. Actual Windows client, root Window size and captured displayed framebuffer are each **1280×720**, stretch transform **(2,2)**.

The graphical capture helper runs the real main scene, sets the exact client size after Windows creates its window, and reads the root Window's displayed framebuffer. It verifies native dimensions/framebuffer/logical size/transform before saving. There is no PNG resizing, enlarged old640px screenshot or character-scale change. An initial borderless sizing mismatch was rejected; all delivered captures are from the correctly sized normal window.

Evidence: `docs/reports/dev-r001-2-display-evidence.json`. Helper: `tests/capture_dev_r001_2.gd`.

## 7. Explicit fence GID profiles

Stored in `world.home.fence_collision_profiles` in craftpix.json. Source GID selects collision; cell-Y heuristic removed. Sizes/offsets are logical pixels relative to the unchanged cell root (tile top-left + (8,16)).

| GID | Piece | Rectangle size | Offset |
| ---: | --- | --- | --- |
| 802 | top-left cap | 7×4 | (4.5,-2) |
| 803 | top rail | 16×4 | (0,-2) |
| 804 | top-right cap | 8×4 | (-4,-2) |
| 819 | left side | 6×16 | (5,-8) |
| 821 | right side | 6×16 | (-4,-8) |
| 836 | bottom-left corner | 6×16 + 7×4 | (5,-8) + (4.5,-2) |
| 837 | bottom rail | 16×4 | (0,-2) |
| 838 | bottom-right corner | 6×16 + 8×4 | (-4,-8) + (-4,-2) |
| 788,789 | open gate | none | — |

Sides align to visible source bases instead of the old tile-center placement. Interior rails retain full width. Fence source pixels, placement, Y-sort origins and gate topology remain untouched.

## 8. One-time measured top-cap bounds

Original exterior.png, tileset firstgid757 /17 columns:

| GID | Original16×16 region | Local opaque bounds (x,y,w,h) | Final world collider |
| ---: | --- | --- | --- |
| 802 | (176,32,16,16) | (9,0,7,16) | X385..392, Y236..240 |
| 804 | (208,32,16,16) | (0,0,8,16) | X584..592, Y236..240 |

Left base occupies source X9..15. Right opaque union occupies X0..7 (lowest four rows X1..7); its8px span includes the joining rail. Previous full-tile bounds were left X376..392 and right X584..600: **9px /8px invisible outer excess removed**, not an assumed symmetric width.

`tests/inspect_fence_source.gd` prints original region/pixel bounds. Runtime uses static profiles, not dynamic alpha-derived collision.

## 9–10. Bottom-corner shapes and gap

Both corners contain vertical and horizontal components. Last ordinary side: Y336..352. Corner vertical: Y352..368, overlapping bottom rail Y364..368. Former **12px uncovered gap →0px**; X alignment with the preceding side is exact. Horizontal cap components join adjacent full rails.

No whole-bottom blocking rectangle; both gate pieces have no shapes.

## 11–12. Physics traversal results

- Both sides: upperY252, middleY300 and lowerY358 block.
- Both old bottom seams: diagonal attempts block.
- GateX520: downward and upward traversal pass.
- Outside shortened caps X379/X598: downward movement passes.
- Visible caps X389/X588: movement blocks.
- Both corners have two shapes, aligned vertical spans and zero gap.

These are real CharacterBody2D move_and_slide attempts inside a fixed physics tick, not shape inspection alone.

## 13. Native captures, all visually reviewed

Every image is **1280×720**, captured from the actual displayed framebuffer:

- [Normal display](../screenshots/dev-r001-2-display-1280x720.png)
- [F2 fence collision](../screenshots/dev-r001-2-fence-collision.png)
- [Physical Right Arrow / F1 facing](../screenshots/dev-r001-2-arrow-input.png)
- [Walk Attack moving](../screenshots/dev-r001-2-walk_attack.png)
- [Run Attack moving](../screenshots/dev-r001-2-run_attack.png)

Review confirms unchanged composition/scale, crisp2× pixels, readable Arrow legend, inward-aligned caps, continuous corners and open gate. Attack captures follow real root movement, not a stationary animation pose.

## 14. Automated results

Godot4.7.2 stable, normal-access execution:

| Suite | Checks | Failures |
| --- | ---: | ---: |
| DEV-R001 source/movement/collision/scene regression | 3,701 | 0 |
| DEV-R001.1 standing attack/home/ambient regression | 14,402 | 0 |
| DEV-R001.2 input/display/fence/moving attacks | 726 | 0 |
| **Total** | **18,829** | **0** |

Audit: **56 original PNGs /four unchanged TMX**. New suite validates every new pose with/without shadow, explicit source columns/timing, final-frame hold, no wrap, one completion, physical J family selection, locked direction/speed/facing, ignored spam/Tab, return to current live input and environment blocking.

Reproduce: Godot `--headless --path <project> --script res://tests/dev_r001_2_test.gd`; corresponding baseline scripts are dev_r001_test.gd and dev_r001_1_test.gd. Capture script requires a graphical run.

## 15. Exact Sword Walk Attack files, mapping and layers

Unchanged originals under art/vendor/craftpix/main_character/male/:

```text
Sword_Walk_Attack_with_shadow.png
Sword_Walk_Attack_without_shadow.png
Sword_Walk_Attack2_sword_back.png
Sword_Walk_Attack3_body.png
Sword_Walk_Attack4_sword_front.png
Sword_Walk_Attack5_head.png
Sword_Walk_Attack6_swing.png
```

State `walk_attack`: sheet384×256, cells64×64,6 steps/direction; Down0/Left1/Right2/Up3; original TMX columns [0,1,2,3,4,5] per row, each150ms, total0.9s, loop=false.

Order: existing Unarmed_Walk1_shadow.png → sword_back → body → sword_front → head → swing. Full with-shadow source confirms reused shadow is correct for all24 poses. Full sheets are validation references; supplied separated layers render at runtime.

## 16. Exact Sword Run Attack files, mapping and layers

```text
Sword_Run_Attack_with_shadow.png
Sword_Run_Attack_without_shadow.png
Sword_Run_Attack2_sword_back.png
Sword_Run_Attack3_body.png
Sword_Run_Attack4_sword_front.png
Sword_Run_Attack5_head.png
Sword_Run_Attack6_swing.png
```

State `run_attack`: sheet512×256, cells64×64,8 steps/direction, same rows; original columns [0,1,2,3,4,5,6,7], each150ms, total1.2s, loop=false.

Order: existing Unarmed_Run1_shadow.png → sword_back → body → sword_front → head → swing. Correct against full source for all32 poses. Human64×64, pivot(32,44), feet10×6 and standing Attack8×150ms unchanged.

## 17. Layer overrides

All **56 new poses** reconstruct both full sheets with **zero pixels beyond the existing1/255 blend-rounding tolerance** in the conceptual order. **No new override needed.** Existing standing Attack Right/step0 override preserved exactly.

`tests/audit_moving_attack_layers.gd` checks every direction/step and searches alternative orders only if a discrepancy occurs. No vendor pixels were edited.

## 18–19. Locked movement and travel

At press: no axis → attack; moving without Shift → walk_attack; moving with Shift → run_attack. Capture normalized axis, facing and48/112px/s speed class once. Steering, spam and Tab cannot alter/restart the one-shot. Standing attack is stationary. Completion immediately reevaluates live Idle/Walk/Run input.

Fixed60Hz unobstructed source-duration measurements:

| State | Measured logical travel | Expected | Display travel at2× |
| --- | ---: | ---: | ---: |
| walk_attack | 43.19934px | 43.2px | about86.4px |
| run_attack | 134.39929px | 134.4px | about268.8px |

Walk Attack reads as a coherent short advancing swing at1280×720. Run Attack keeps source-facing/pivot coherence but has a conspicuously long commitment (about4.2 logical32px world units). This is a provisional visual-review judgment, not user playtest approval/final tuning. **Flag Run Attack distance and steering lock for the next design decision. No speed or source timing retune.**

## 20. Moving attack collision

Run Attack toward fence, house and tree blocks naturally, travels less than40px in each fixture, still finishes once and returns to current Idle input. Walk/Run share the captured-velocity move_and_slide path. Collision may stop/slide the root but never teleports through geometry or changes locked source facing.

No damage, hitbox, hurtbox, HP, stamina, knockback, combos, weapon stats, inventory, NPC, fauna/house/map expansion or generated art. Autonomous boar unchanged.

## 21. Provenance, license and replacement

PROVENANCE.md records exact14 Drive links/sizes, original-file hashes through the audit, user's official-free prototype authorization and replacement/compliance status. **ART-002 →11 License & Replacement Ledger** remains the final release gate. Public/commercial use requires exact-pack clearance/proof or legal final-art replacement; prototype permission is not blanket future-distribution clearance. No remote ART edit or Git push.

WORKLOG updated. Stop for user visual review / next explicit handoff.
