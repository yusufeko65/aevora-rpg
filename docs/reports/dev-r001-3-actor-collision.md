# DEV-R001.3 — Actor collision correction

Delivered 2026-10-04. Parent: `4170ce8e714baa116d08068b17439e82decd5cd3`.
Result: implementation commit containing this report; exact SHA is supplied in the final delivery response. No remote push.

## Scope and starting condition

Fix physical Player↔Boar occupancy, formalize named collision layers, preserve DEV-R001.2. No art/collider enlargement, avoidance, combat or interaction systems. No CONTEXT.md.

Read the handoff, latest relevant WORKLOG sections, DEV-R001.2 report and active code before implementation. Three pre-existing tracked edits were found: JSON reformat/property ordering in craftpix.json and craftpix_audit.json, and editor UID/unique-ID metadata in main.tscn. Recursive comparison confirmed both JSONs are semantically identical to parent. Their exact starting SHA-256 hashes remained unchanged through this work; these edits and five pre-existing screenshot .import files are preserved and excluded from this commit.

## Why pass-through occurred

Previously Player used implicit defaults layer1/mask1, Boar layer4/mask2. House/fence/trees were layer3 (Player+Environment); world boundaries used default layer1. Environment's mixed bits let Player and Boar both detect those static objects, but neither actor's mask selected the other actor's layer. It was a classification problem, not sprite/feet size.

## Starting and final matrix

Layer names added to project.godot: layer1 Player, layer2 Environment, layer3 Fauna.

| Body | Starting layer/mask | Final layer/mask | Actor detects |
| --- | --- | --- | --- |
| Player | 1 /1 (implicit) | **1 /6** (explicit) | Environment2 +Fauna4 |
| Boar | 4 /2 | **4 /3** | Player1 +Environment2 |
| House/fence/trees | 3 /1 | **2 /1** | Static bodies; default mask retained |
| World boundaries | 1 /1 (implicit) | **2 /1** | Static body; default mask retained |

Environment is now on layer2 only. Static mask1 remains unchanged; moving actors' masks select Environment. Boar mask excludes Fauna4: fauna-vs-fauna blocking is not introduced. Physics labels are editor-visible; no new gameplay singleton/framework.

## Environment migration and preservation

Migrated:

- Dynamically built House and all **42 Fence pieces** (40 solid, two open-gate pieces) from layer3 to2.
- Five trunks: Tree64, Tree128, Tree128West, Tree64South, Tree64East from3 to2.
- Boundaries from implicit1 to explicit2; same Top/Bottom/Left/Right shapes.

Runtime audit: **49 StaticBody2D nodes**, **47 with shapes**, **52 unchanged static collision shapes**. Every static body uses layer2 only. Gate pieces remain shapeless.

Only layer declarations changed in world scene/script. All source-GID fence profile sizes/offsets, sprite placements, static footprints and Y-sort roots are unchanged. Player feet remain10×6 at(0,-1); Boar16×8 at(0,-2). Human frame64×64, pivot(32,44), walk/run48/112px/s, all source timings/mappings/layer overrides and ambient controller code remain unchanged. All56 PNG/four TMX byte hashes match the preserved source audit. Provenance/license policy unchanged; no new assets.

## Deterministic actor tests

New suite: tests/dev_r001_3_test.gd. Actors' automatic processing is paused for deterministic fixed60Hz probes; the real controllers and move_and_slide are called. After each fixture reset, a physics tick synchronizes the stationary actor before motion tests. Every movement tick checks the intersection area of actual feet rectangles; touching is permitted, penetration is not.

| Test group | Directions | Result |
| --- | ---: | --- |
| Player walks into stationary Boar | Four cardinal +four diagonal | Contact blocks direct travel or deflects sliding; no penetration |
| Player runs into stationary Boar | Four cardinal +four diagonal | Same, at112px/s |
| Ambient Boar walks toward stationary Player | Four cardinal +four diagonal | No pass-through; controller stops/idles or slides naturally |
| Walk Attack into Boar | Four cardinal +four diagonal | Root advances, meets contact, animation keeps playing and finishes once |
| Run Attack into Boar | Four cardinal +four diagonal | Same, unchanged8×150ms source timing |

**40 directional contact cases**, **0.0 logical pixel² final penetration in all cases**, with no material penetration on any checked movement tick.

Direct Player normal travel from32px root separation stops after about19px horizontally,24px from above and26px from below. Different vertical distances reflect the original feet offsets/sizes, not adjusted colliders. Boar direct travel from28px separation stops after about15px horizontally,20px from below and22px from above.

Each blocked attack plays every full source duration (54/72 fixed ticks), completes exactly once and does not emit again after further advancement. Released input returns to Sword Idle; an additional blocked Run Attack test with current Left input returns immediately to Walk Left. No damage, reaction, hostility, aggro, prompt or knockback occurs.

Machine-readable per-case positions, projected progress, completion counts and contact observations: [physics evidence](dev-r001-3-physics-evidence.json).

## Sliding/contact observations

Direct contact stops movement. Held diagonal Player input can slide along a Boar edge and then go around it while maintaining non-overlapping feet. That is legal move_and_slide behavior, not tunneling: tests check real occupancy on every tick and require a collision/deflected path rather than falsely requiring permanent root immobility.

Boar cardinal contact naturally invokes existing idle behavior. At diagonal contact the existing controller can retain Walk while sliding tangentially; observed end velocities were about1.94–2.70px/s, derived from actual displacement. Facing follows observed velocity. No avoidance/pathfinding or new Boar response was added.

At the captured vertical contacts, feet gaps were approximately0.00043–0.00183 logical px and overlap area0.0. Sprite canvases/bodies may visually overlap because source art is larger than the deliberately small unchanged feet shapes; rendering order and physical occupancy are separate.

## Y-sort and F2 display verification

Both actors retain their common Actors parent with dynamic Y-sort, zero actor z-index and unchanged visual roots. Captures from below and above show the lower-ground-root actor composited in front; collision-layer changes did not alter rendering configuration.

F2 is invoked through the existing overlay handler. Player feet, Boar feet and static footprints remain visible. Every screenshot is the **actual native1280×720 root Window framebuffer**, logical640×360, stretch(2,2); no image resizing.

- [Player–Boar contact from below](../screenshots/dev-r001-3-player-boar-collision.png)
- [Contact from above / Y-sort comparison](../screenshots/dev-r001-3-player-boar-y-sort-above.png)
- [Run Attack blocked at Boar, mid-animation](../screenshots/dev-r001-3-run-attack-boar-block.png)

[Display/contact evidence](dev-r001-3-display-evidence.json) records actual window/framebuffer dimensions, F2 state, poses, positions, feet rectangles and measured gaps. The capture script also confirms Run Attack completes once after its mid-animation screenshot.

## Regression results

Godot4.7.2 stable, Compatibility; all suite processes exit0 without parser/runtime errors in final verification.

| Suite | Checks | Failures |
| --- | ---: | ---: |
| DEV-R001 | 3,701 | 0 |
| DEV-R001.1 | 14,402 | 0 |
| DEV-R001.2 | 726 | 0 |
| DEV-R001.3 | 4,332 | 0 |
| **Total** | **23,161** | **0** |

Previous DEV-R001.1 assertion was updated from Boar mask2 to3 to reflect the new required contract; it was not removed. Other previous test logic is unchanged.

Old suites preserve Arrow/WASD input, Idle/Walk/Run, all three sword attack pixel/timing/one-shot behaviors, source geometry, gate traversal and corrected fence seams/caps. New suite adds both actors against house/fence/tree and all four world boundaries, plus actor/Y-sort contracts. For Boar's environment fixtures only, the test widens roam_area so original clamping does not relocate probes from yard/tree/boundary positions; production roam_area/controller are untouched.

## Files changed

Runtime/config:

- project.godot — three editor-visible physics names.
- scenes/player/player.tscn — explicit1/6.
- scenes/fauna/boar_preview.tscn — mask2→3.
- scenes/world/test_world.tscn — five trees and boundary on Environment2.
- scenes/world/test_world.gd — house/fence on Environment2.

Validation/documentation:

- tests/dev_r001_1_test.gd — expected Boar mask updated.
- tests/dev_r001_3_test.gd — deterministic matrix/contact/environment suite.
- tests/capture_dev_r001_3.gd — native display/F2 contact captures.
- docs/reports/dev-r001-3-physics-evidence.json and dev-r001-3-display-evidence.json.
- Three screenshots linked above.
- This report and supplied DEV-R001.3 handoff.
- WORKLOG.md — short “DEV-R001.3 delivered actor collision correction” section.

No SourceSprite/Player/Boar controller code, mapping, source art, F2 implementation or provenance edits. Pre-existing unrelated edits remain outside this commit.

## Problems encountered / failed attempts

- Initial inventory accidentally asked for Git status from the workspace parent and tried non-existent short boar filenames. Correct repository and boar_preview paths were then inspected; no files were altered by those checks.
- First test draft called normalized() in a GDScript constant, which is not a constant expression. Direction vectors now initialize as test variables.
- Repositioning two CharacterBody2D fixtures and immediately testing in the same tick left the stationary body's physics transform stale. This produced false collision failures; synchronizing each reset with the next physics tick resolved them without runtime changes.
- Early tests incorrectly required diagonal contact to remain permanently stopped and Boar to always Idle. Actual zero-overlap sliding is explicitly permitted by the handoff, so tests now assert contact, deflection and nonpenetration.
- Completion counting initially filtered an attack pose after the Player's earlier completion handler had already switched pose. Counting the signal invocation itself correctly verifies one completion.
- Final graphical capture worked first run at native1280×720; no scale/collider retuning was required.

## Deviations, lessons and deferred items

No gameplay deviations. Added only editor layer names and supplementary Y-sort/contact evidence beyond the minimum capture. No CONTEXT.md, no combat systems, no fauna-vs-fauna collision, no new third-party assets, no remote push.

Lessons: give each occupancy class one explicit layer; migrate every static body including boundaries; inspect bitmasks rather than art when actors pass through; synchronize physics fixtures before collision probes; allow natural sliding while checking real occupancy; count completion events independently of state transitions. Keep WORKLOG concise and detailed reasoning in this report.

Known/deferred: small feet footprints intentionally permit sprite overlap; diagonal tangential sliding uses current controller behavior; Run Attack's provisional134.4px unobstructed commitment/steering lock remains the DEV-R001.2 design-review item. No avoidance, damage, reactions, hitboxes, interaction, inventory or sprite-production integration was started.

## Recommended next handoff

Stop for review. The R001 technical foundation now passes actor/environment, animation/input and display checks; treat it as technically validated after user visual approval. Explicitly choose **Track A: Asset Production R&D** (original AEVORA64×64 pipeline) or **Track B: Gameplay Foundation** (a deliberately selected core system). Neither track begins automatically.
