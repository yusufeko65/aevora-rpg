# DEV-003 — Prototype Stabilization & Interaction Contract / Codex Handoff

**AEVORA • Godot 4 • Stabilization after DEV-001 and DEV-002**

Status: Implementation correction handoff.  
Scope: stabilize the current prototype before adding new gameplay systems.

---

## 1. Purpose

DEV-003 is a **correction and stabilization pass**, not a feature-expansion pass.

DEV-001 successfully established the reusable Godot foundation.  
DEV-002 successfully replaced the greybox with a recognizable visual slice, but implementation review exposed several ambiguities that must be corrected before farming, NPC simulation, knowledge/inquiry, combat, property, or other systems are added.

The goal of DEV-003 is to make the current prototype predictable and technically clean in four areas:

1. prototype asset handling;
2. player/world collision;
3. bridge and environmental traversal;
4. interaction/dialogue lifecycle.

Do not expand the game scope until all DEV-003 acceptance tests pass.

---

## 2. Required Reading Before Editing

Codex must inspect the current repository and read:

- `docs/handoff/DEV-001-godot-project-foundation.md`
- `docs/handoff/DEV-002-first-visual-slice.md`
- current `WORKLOG.md`
- current Player scene/script
- current PrototypeZone scene/script
- current NPC and InteractionTarget implementation
- current HUD/message implementation
- current DEV-002 smoke tests

Also preserve the design intent from the Google Drive source-of-truth documents already referenced by DEV-001/DEV-002.

Do not assume that a behavior from DEV-002 is correct merely because the smoke test passes.

---

## 3. Known Issues Confirmed by User Review

The following issues are **explicitly known and must be addressed**.

### 3.1 Prototype image source size

The first DEV-002 images were much larger than their intended in-game footprint and were scaled down heavily in Godot.

The user has now:

- compressed the prototype images;
- resized the replacement images to **256 px**;
- prepared them as replacements for the current DEV-002 image files.

Codex must replace the existing prototype image files with the new 256 px versions when they are present at the expected paths.

**Important:** preserve the existing filenames and repository paths where possible so scenes do not need unnecessary path changes.

Expected paths remain:

```text
res://art/prototype/dev_002/
  buildings/
    tropical_pixel_village_cottage.png
    pixel_art_thatched_village_cottage.png
  environment/
    lush_tropical_pixel_art_tree_sprite.png
    pixel_art_vegetable_garden_plot.png
    tropical_pixel_fence_corner.png
    rustic_pixel_art_wooden_bridge.png
  characters/
    four_direction_villager_sprite_sheet.png
    pixel_farmer_villager_sprite_sheet.png
```

If a replacement image is not yet present locally, do not generate a substitute and do not overwrite the existing image. Report it as pending.

### 3.2 Bridge traversal is incorrect

Current behavior can allow the player to visually/collision-wise pass through only part of the bridge or become inconsistent with the river blockers.

The bridge must become an explicit traversal corridor, not merely a sprite placed over gaps in river collision.

### 3.3 Farm/crop and tree collision are insufficient

The player can currently pass through environmental elements in ways that do not match the intended physical world.

Tree collision is too permissive relative to the character and sprite footprint.

The farm/garden area also lacks a clearly defined physical policy.

### 3.4 Dialogue/message remains visible after leaving interaction range

Current HUD behavior shows the interaction result for a fixed timer.

This is insufficient.

If the player moves away from the NPC/object that originated the message, the interaction panel must close according to the lifecycle contract in this document.

---

## 4. Implementation Principle

From DEV-003 onward, Codex must distinguish clearly between:

```text
VISUAL FOOTPRINT
PHYSICAL FOOTPRINT
INTERACTION FOOTPRINT
```

They are not the same thing.

Examples:

```text
Tree:
Visual footprint     = full canopy + trunk
Physical footprint   = trunk/root area
Interaction footprint = only if the tree is interactable

NPC:
Visual footprint     = whole sprite
Physical footprint   = feet/body capsule
Interaction footprint = larger radius around NPC

Bridge:
Visual footprint     = complete bridge sprite
Physical footprint   = walkable corridor + blocking side edges
```

Do not derive collision automatically from full sprite bounds.

---

# 5. Asset Replacement Contract

## 5.1 Preserve source files

The new 256 px files are the new prototype sources.

Do not:

- resize them again destructively;
- overwrite them with generated derivatives;
- convert them to another source format without reason;
- modify the original PNG pixels just to solve scene scale.

Godot import artifacts may be regenerated normally.

## 5.2 Re-import after replacement

After replacing the files:

1. trigger/recheck Godot import;
2. ensure no broken UID/path references;
3. inspect every affected Sprite2D;
4. re-tune scene scale based on the new source dimensions;
5. remove obsolete scaling assumptions inherited from the old large PNGs.

The current values such as:

```gdscript
scale = Vector2(0.16, 0.16)
scale = Vector2(0.17, 0.17)
scale = Vector2(0.20, 0.20)
scale = Vector2(0.24, 0.24)
```

must **not** be preserved blindly.

They were derived from the oversized DEV-002 source images.

## 5.3 Pixel rendering

Required:

- nearest-neighbor filtering;
- no mipmaps for current prototype pixel assets;
- preserve aspect ratio;
- integer/pixel-conscious placement where practical;
- no arbitrary non-uniform scaling.

Preferred Sprite2D scale:

```text
(1,1)
```

or another deliberate integer/fixed prototype scale.

Fractional scaling is acceptable only if unavoidable for the temporary pack and must be documented in `WORKLOG.md`.

## 5.4 Visual target

A 256 px source does **not** mean a 256 px in-world footprint.

Codex must judge the intended gameplay size from:

- player scale;
- provisional 32×32 logical tile baseline;
- walkable spacing;
- top-down 3/4 visual proportion.

Do not enlarge the character or object collision merely to match the transparent canvas size of the PNG.

---

# 6. Player Physical Collision Contract

Current player collision is approximately:

```text
CapsuleShape2D
radius = 7
height = 17
```

DEV-003 must review this against the current visible player sprite.

The collision represents the player's **feet/body occupancy on the ground**, not the entire sprite.

## Required behavior

The player:

- cannot enter solid environmental footprints;
- should not collide based on head/hair sprite height;
- should move cleanly around object corners;
- should not visually overlap deeply into tree trunks, fences, buildings, or impassable crop rows.

## Tuning rule

Do not simply make the player collision “very large”.

Instead, adjust:

```text
player ground capsule
+
environment physical footprint
```

together.

Target player ground footprint should roughly represent the lower body/feet.

Document the final dimensions chosen in `WORKLOG.md`.

---

# 7. Tree Collision Contract

Tree collision must represent the trunk/root base.

The canopy is primarily visual and may overlap the player for depth presentation.

## Required structure

For each tree:

```text
TreeRoot Node2D
├── Sprite2D / visual
└── StaticBody2D or shared environment body
    └── CollisionShape2D at trunk/base
```

A shared StaticBody2D is acceptable if coordinates remain maintainable.

## Required behavior

Player approaches the trunk from:

- north;
- south;
- east;
- west;
- northeast;
- northwest;
- southeast;
- southwest.

The player must not cross through the trunk footprint.

The player **may** visually move behind canopy portions when depth sorting permits.

## Collision sizing

Current `radius = 18` must be treated as provisional.

Tune it using the actual resized sprite and player footprint.

The collider should normally cover the visible trunk/root base, not the full foliage.

## Acceptance test

For every prototype tree:

```text
[PASS] cannot cross trunk north → south
[PASS] cannot cross trunk south → north
[PASS] cannot cross trunk east → west
[PASS] cannot cross trunk west → east
[PASS] diagonal corner clipping does not pass through trunk
[PASS] canopy does not act as a giant invisible wall
```

---

# 8. Crop / Garden Physical Policy

DEV-002 did not define this clearly enough.

For the current prototype, use the following rule:

> **Crop rows are physical low obstacles; player may walk on intentional paths around/between them, but may not walk directly through planted crop rows.**

The whole garden sprite must **not** become one giant rectangular blocker.

## Required implementation

Represent the crop plot with multiple simple collision strips/rectangles aligned to visible planted rows.

Leave walkable gaps where the image visually contains paths.

If the current prototype sprite does not visually contain meaningful internal paths, block the planted core but preserve an outer walking margin.

## Acceptance test

```text
[PASS] player cannot cut straight through planted rows
[PASS] player can walk around the plot
[PASS] player is not blocked by excessive transparent image padding
[PASS] collision visually corresponds to the crop area
```

This is a prototype policy and can later be replaced by the farming system's tile/state collision.

---

# 9. Fence Collision Contract

Fence collision must follow actual rails/posts.

Do not block the whole visual bounding box.

Intentional openings/gates must remain traversable.

Acceptance:

```text
[PASS] player cannot walk through fence rails
[PASS] player can pass through intended opening
[PASS] corners do not allow obvious diagonal clipping
```

---

# 10. Bridge and River Traversal Contract

This is a critical DEV-003 correction.

## 10.1 River

The river is not walkable in the current prototype.

There is no swimming system yet.

Therefore:

```text
RIVER WATER
= prohibited movement area
```

except where a valid bridge traversal corridor exists.

## 10.2 Bridge

Bridge traversal must be modeled explicitly.

Conceptually:

```text
      RIVER BLOCKER
──────────┐      ┌──────────
          │BRIDGE│
──────────┘      └──────────
      RIVER BLOCKER
```

The bridge must provide:

1. a clearly defined walkable corridor;
2. blocking side edges so the player does not step sideways into water while on the bridge;
3. clean entry/exit at both ends.

## 10.3 Do not use only four river collision rectangles

The implementation may use several CollisionShape2D nodes, polygons, or another clear method, but the resulting geometry must represent:

```text
water = blocked
bridge deck = walkable
bridge sides = bounded
```

## 10.4 Visual and collision alignment

After the new 256 px bridge image is imported, recalculate:

- bridge position;
- bridge rotation;
- visible deck width;
- entry points;
- river collision gaps;
- side collision.

Do not preserve DEV-002 coordinates/scale blindly.

## Acceptance test

Player must successfully perform:

```text
north bank → bridge → south bank
south bank → bridge → north bank
```

without:

- being blocked halfway;
- passing through the bridge side;
- entering river beside the bridge;
- getting stuck at either bridge endpoint.

Also test diagonal input while crossing.

---

# 11. House Collision Contract

House collision represents structural footprint/walls.

The roof is visual.

Required:

```text
[PASS] player cannot walk through house walls
[PASS] player can approach the entrance
[PASS] roof/upper sprite does not create excessive invisible collision
[PASS] collision aligns with resized house sprite
```

Interior transition is not part of DEV-003.

---

# 12. Interaction Focus Contract

Current interaction uses an `Area2D` radius and selects the nearest `InteractionTarget`.

Keep that reusable architecture, but formalize its behavior.

Define:

```text
interaction_enter_radius
interaction_exit_radius
```

Use slight hysteresis if useful:

```text
exit_radius >= enter_radius
```

Example only:

```text
enter = 44 px
exit  = 56 px
```

These numbers are tuning values, not mandatory values.

The final values must be documented.

## Focus rules

A target is focused when:

- it is valid;
- it can interact;
- it is inside interaction range;
- it wins nearest-target selection.

Focus must clear when:

- target exits the allowed range;
- target becomes invalid/freed;
- `can_interact()` becomes false;
- another nearer valid target replaces it.

`focused_target_changed` should remain the authoritative signal for UI that depends on target focus.

---

# 13. Interaction Message / Dialogue Lifecycle

The current fixed 4-second message timer is insufficient.

DEV-003 must distinguish between:

```text
interaction prompt
interaction message/dialogue
```

## 13.1 Prompt

Prompt example:

```text
[E] Talk to Farmer
```

Prompt is visible only while a valid target is focused.

When focus is lost:

```text
prompt closes immediately
```

## 13.2 Message/dialogue session

When an interaction produces a message, the UI must retain the **source interaction target**.

Recommended conceptual state:

```text
CLOSED
  ↓ interact
OPEN(source_target)
```

The message remains valid only while the source target/session is valid.

## 13.3 Required automatic close conditions

Close the interaction message immediately when any of the following occurs:

- player moves outside `interaction_exit_radius` from the source target;
- source target becomes invalid;
- source target becomes non-interactable;
- world/zone is changed;
- a new incompatible interaction replaces it.

Do **not** rely solely on a timer.

## 13.4 Timer behavior

For prototype single-line messages, a timeout may still exist as a secondary rule.

For example:

```text
close if:
distance invalid
OR source invalid
OR timeout reached
```

Distance/source invalidation takes precedence.

## 13.5 Moving away

User-reported case:

```text
player talks/reads
→ message panel appears
→ player walks away
→ panel remains visible
```

This must be fixed.

Required result:

```text
player leaves interaction range
→ source session invalidated
→ message panel hidden
→ stored source cleared
→ prompt reflects current focus only
```

## 13.6 Message ownership

Change the interaction event/API if necessary so the UI can know the source.

For example, instead of only:

```gdscript
interaction_completed(message: String)
```

prefer a contract equivalent to:

```gdscript
interaction_completed(source: InteractionTarget, message: String)
```

or a small interaction result object.

Do not implement a large dialogue framework yet.

The only requirement is that message ownership and lifecycle are deterministic.

---

# 14. Interaction State Edge Cases

Codex must explicitly test:

### Case A — NPC

```text
approach NPC
prompt appears
interact
message appears
walk away
prompt disappears
message disappears
```

### Case B — Sign/object

```text
approach sign
prompt appears
read
message appears
walk away
message disappears
```

### Case C — Two targets

```text
two interactables overlap range
nearest is focused
move closer to second
focus switches
no duplicate message panels
```

### Case D — Invalid source

If an interacted target is removed/freed while message is open:

```text
no crash
message closes
source reference clears safely
```

### Case E — Repeated interact

Repeated `E`/Space must not spawn multiple UI instances.

---

# 15. UI Contract

Keep the current HUD lightweight.

Normal game mode:

- debug panel hidden;
- prompt panel hidden unless focus exists;
- message panel hidden unless active interaction message exists.

Debug mode may show:

- player world position;
- focused target ID/name;
- active interaction source;
- enter/exit radius;
- FPS;
- collision debug state if implemented.

Do not mix debug labels into the world.

---

# 16. Collision Debugging Requirement

DEV-003 should provide an easy way to verify collision.

Preferred:

- Godot visible collision shapes during development, and/or
- F1/F-key debug mode that can expose relevant state.

Codex must use collision visualization while verifying:

- player capsule;
- tree trunks;
- crop rows;
- fences;
- house footprint;
- river blockers;
- bridge corridor and side blockers.

A visual screenshot alone is not sufficient verification.

---

# 17. Tests to Add / Update

The existing DEV-002 smoke test checks scene presence but not enough physical behavior.

Add targeted automated tests where practical.

At minimum verify structurally:

- required colliders exist;
- river blocker does not cover bridge corridor;
- bridge corridor is represented;
- garden has physical row/core collision;
- interaction signal/result carries source ownership;
- HUD closes session when source becomes invalid.

Some movement/collision behavior may still require Godot MCP runtime/manual simulation.

Document which acceptance items are automated and which are runtime-verified.

---

# 18. Godot MCP Verification Procedure

Codex must not finish DEV-003 after editing files only.

Required sequence:

1. open/import project;
2. confirm no parser errors;
3. confirm new 256 px replacements imported successfully;
4. run smoke/unit tests;
5. run main scene;
6. enable collision visualization;
7. test tree from multiple directions;
8. test crop plot;
9. test fence;
10. cross bridge both directions;
11. attempt to enter river beside bridge;
12. interact with farmer and walk away;
13. interact with sign and walk away;
14. verify UI closes correctly;
15. check output/debugger for new errors/warnings;
16. capture final clean screenshot;
17. append DEV-003 results to `WORKLOG.md`.

Do not mark DEV-003 complete merely because the game launches.

---

# 19. Files Expected to Change

Likely files include, but are not limited to:

```text
art/prototype/dev_002/**                 # replacement PNG files supplied by user
scenes/player/player.gd
scenes/player/player.tscn
scenes/world/prototype_zone.tscn
scenes/npc/**
scenes/interactables/**
scenes/ui/debug_hud.gd
scenes/ui/debug_hud.tscn
tests/**
WORKLOG.md
```

Codex may introduce a small reusable interaction-session/result script if that produces cleaner ownership semantics.

Do not introduce a large event bus, dialogue engine, ECS, or unrelated architecture.

---

# 20. Do Not Change

Unless required to fix an actual regression, preserve:

- Godot Compatibility renderer;
- project main scene;
- reusable CharacterBody2D player architecture;
- separation of world collision layer and interaction layer;
- reusable `InteractionTarget` concept;
- stable NPC identity/resource approach;
- integer window scaling;
- current repository structure;
- DEV-001 and DEV-002 handoff files.

Do not rewrite the whole prototype.

---

# 21. Out of Scope

DEV-003 does **not** add:

- farming gameplay;
- crop planting/harvesting;
- seasons;
- weather;
- NPC schedules;
- NPC employment;
- Knowledge & Inquiry;
- inventory;
- mining;
- fishing;
- combat;
- property purchase;
- construction;
- city/guild systems;
- final art production;
- swimming.

---

# 22. Acceptance Matrix

DEV-003 is not complete until all items below pass.

## Assets

```text
[ ] Replacement 256 px PNGs imported where available
[ ] Existing file paths preserved where practical
[ ] No broken texture references
[ ] No obsolete extreme scale values kept blindly
[ ] Pixel edges remain crisp
```

## Player

```text
[ ] Ground collision footprint reviewed and documented
[ ] Movement remains smooth
[ ] No regression in camera
```

## Trees

```text
[ ] Cannot walk through trunks
[ ] Diagonal clipping tested
[ ] Canopy does not become full invisible wall
```

## Crops

```text
[ ] Cannot walk through planted crop rows/core
[ ] Can walk around plot
[ ] Transparent image padding does not block player
```

## Fence

```text
[ ] Fence rails block movement
[ ] Intended gap remains walkable
```

## House

```text
[ ] Walls/footprint block movement
[ ] Entrance approach remains reachable
```

## River / Bridge

```text
[ ] River cannot be entered outside bridge
[ ] Bridge can be crossed north → south
[ ] Bridge can be crossed south → north
[ ] No halfway collision failure
[ ] No sideways river leak from bridge
[ ] Diagonal bridge movement tested
```

## Interaction

```text
[ ] Prompt appears in range
[ ] Prompt closes immediately out of range
[ ] Message records its source target
[ ] NPC message closes when player walks away
[ ] Sign/read message closes when player walks away
[ ] Invalid/freed source closes safely
[ ] Repeated interact creates no duplicate panel
```

## Runtime

```text
[ ] No blocking parser errors
[ ] No new runtime errors
[ ] Tests pass
[ ] Collision visualization reviewed
[ ] Clean screenshot captured
[ ] WORKLOG.md updated with actual final values
```

---

# 23. Required Worklog Details

At completion, append a `DEV-003 stabilization` section to `WORKLOG.md` containing:

- replacement assets actually found/replaced;
- final player collision shape and dimensions;
- final tree collider dimensions;
- garden collision strategy;
- fence collision strategy;
- bridge corridor dimensions/implementation;
- interaction enter radius;
- interaction exit radius;
- message timeout, if retained;
- exact message close conditions;
- tests added;
- MCP/manual verification results;
- any remaining known issues.

Do not report a value that was not actually implemented.

---

# 24. Definition of Done

DEV-003 is complete when the current AEVORA prototype is a stable base rather than merely a visually improved mock-up.

A player must be able to:

```text
walk around the home area
→ be physically blocked by believable objects
→ navigate crop/fence/tree boundaries
→ cross the bridge cleanly
→ remain outside the river
→ approach NPC/sign
→ interact/read
→ walk away
→ see interaction UI close correctly
```

Only after this behavior is verified should the next handoff introduce new gameplay systems.
