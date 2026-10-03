# DEV-R001 — Restart Baseline v2 / Craftpix Asset-First Foundation

**AEVORA • Godot 4 • Restart Baseline • Craftpix Source Audit**

Status: **Implementation handoff — new baseline**  
Purpose: restart the playable Godot implementation from a clean asset-first foundation using the audited Craftpix `.tmx` + `.png` source as the technical reference.

---

## 0. Supersession / Reset Rule

This handoff **supersedes the implementation output of DEV-001, DEV-002, DEV-003, and DEV-004**.

The previous implementation remains valuable as Git history and engineering evidence, but it is no longer the runtime baseline.

Do **not** rewrite Git history, force-push, squash away, or delete the historical handoff documents merely to make the repository look clean.

Required approach:

```text
existing Git history
        ↓ keep
old DEV-001..004 runtime prototype
        ↓ remove/replace in a normal commit
DEV-R001 clean runtime baseline
```

The old handoff documents may remain under `docs/handoff/` as historical records. Add a clear supersession note if useful.

The new implementation must **not inherit old prototype assumptions just because old code already exists**.

---

# 1. Why the project is restarting

The previous prototype successfully tested several architectural ideas, but the temporary/generated visual assets did not meet the required AEVORA character quality.

The new baseline uses real Craftpix source files as:

- technical layout reference;
- sprite-frame reference;
- animation-state reference;
- row/direction mapping reference;
- frame-count reference;
- timing reference;
- layer-composition reference;
- tile and environmental scale reference.

Craftpix art is currently a **technical/source reference and development asset**, not automatically the final canonical AEVORA art direction.

Do not reinterpret Craftpix source into a different frame layout before it has been tested faithfully.

---

# 2. Source of Truth Before Coding

Codex must review the current Google Drive sources before implementation.

## 2.1 ART-001 — Visual Direction

Use the current ART-001 spreadsheet.

Important current lock:

```text
STANDARD HUMAN CHARACTER SPRITE FRAME = 64×64 px
```

This means:

```text
sprite frame size = 64×64
```

It does **not** mean:

```text
visible body fills 64×64
collision = 64×64
world footprint = 64×64
```

Keep these concepts independent.

## 2.2 ART-002 — Asset Registry

Use the current ART-002 spreadsheet, especially:

```text
01 Asset Master
03 Animation & Frame
10 Craftpix Source Audit
```

`10 Craftpix Source Audit` is the current source-geometry audit produced from the uploaded `.tmx` and `.png` files.

Do not silently change a source mapping because an older DEV handoff used a different convention.

## 2.3 Google Drive Craftpix source folders

Under:

```text
07 - Art & Visual
```

relevant folders are:

```text
Main Character/
  Male/
  Home/
  Farm/

Fauna/
  Hunt Animal/

Flora/
  Tree/

Tile/
  Path and Road/
```

The implementation should begin with a **small verified subset**, not import every file into active runtime usage at once.

---

# 3. Locked Technical Decisions for This Restart

## 3.1 Character frame size

LOCKED:

```text
standard human character frame = 64×64 px
```

A standard character animation sheet is composed from 64×64 cells.

Example:

```text
Walk:
6 frames × 4 directions
= 384×256 PNG
```

because:

```text
6 × 64 = 384
4 × 64 = 256
```

Do not downscale the source assets to 32×32 as part of the import pipeline.

Do not upscale the visible character body to fill the 64×64 cell.

---

## 3.2 World logical tile

Current world reference remains:

```text
32×32 logical world tile
```

However many Craftpix environment `.tmx` files use:

```text
16×16 source tiles
```

These are separate concepts.

Do not conclude that the AEVORA logical world tile must become 16×16 merely because the source tileset was authored on a 16×16 Tiled grid.

The first technical slice should prove how 16×16 source tiles can coexist with AEVORA's world composition.

If a permanent scale conversion is required, report the evidence before changing ART-001.

---

## 3.3 Renderer / viewport

Keep the technically useful project settings unless testing proves a problem:

```text
Godot 4
Compatibility renderer
logical viewport = 640×360
reference display = 1280×720
integer scaling
```

Do not reintroduce generated prototype art.

---

# 4. Craftpix Main Character — Verified Source Contract

Primary source:

```text
Main Character/Male/Base_boy.tmx
```

Important distinction:

```text
TMX tileset tile size = 16×16
logical character animation frame = 64×64
```

The TMX internally describes animation through 16×16 subtiles, but the complete character pose occupies a 64×64 logical frame.

For AEVORA runtime character handling, treat the **logical pose frame as 64×64**.

---

# 5. Main Character Direction Mapping

The audited Craftpix character source uses this direction order:

```text
row 0 = Down
row 1 = Left
row 2 = Right
row 3 = Up
```

Preserve the original PNG source order.

Do not physically reorder the PNG merely to satisfy an engine convention.

Runtime code should use explicit semantic direction names:

```text
down
left
right
up
```

and map them to source rows.

For example:

```gdscript
const SOURCE_ROW := {
    "down": 0,
    "left": 1,
    "right": 2,
    "up": 3,
}
```

This mapping belongs in data/configuration where practical rather than being duplicated across gameplay code.

---

# 6. Main Character Animation Frameset

The following values come from the audited Craftpix source and should be reproduced exactly in the first technical test.

| State / Source | PNG Size | Logical Cell | Columns | Direction Rows | Frames / Direction |
|---|---:|---:|---:|---:|---:|
| Unarmed Idle | 768×256 | 64×64 | 12 | 4 | 12 |
| Unarmed Walk | 384×256 | 64×64 | 6 | 4 | 6 |
| Unarmed Run | 512×256 | 64×64 | 8 | 4 | 8 |
| Unarmed Hurt | 320×256 | 64×64 | 5 | 4 | 5 |
| Unarmed Death | 448×256 | 64×64 | 7 | 4 | 7 |
| Sword Idle | 768×256 | 64×64 | 12 | 4 | 12 |
| Sword Walk | 384×256 | 64×64 | 6 | 4 | 6 |
| Sword Run | 512×256 | 64×64 | 8 | 4 | 8 |
| Sword Attack | 512×256 | 64×64 | 8 | 4 | 8 |
| Sword Walk Attack | 384×256 | 64×64 | 6 | 4 | 6 |
| Sword Run Attack | 512×256 | 64×64 | 8 | 4 | 8 |
| Sword Hurt | 320×256 | 64×64 | 5 | 4 | 5 |
| Sword Death | 448×256 | 64×64 | 7 | 4 | 7 |

These counts are **source facts for this Craftpix character**.

Do not convert them into a global AEVORA rule saying every future character must use exactly those counts.

---

# 7. Main Character Timing

The audited Craftpix character animations primarily use:

```text
150 ms per animation frame
```

Death uses a longer final hold in the audited source:

```text
first frames ≈ 150 ms
final frame ≈ 300 ms
```

For the first implementation:

> reproduce the source timing faithfully before tuning the feel.

Do not immediately replace the source timing with old DEV-004 timing ranges.

The purpose of this pass is to learn what the actual purchased/reference animation feels like inside AEVORA's viewport.

After runtime review we may tune timing per state.

Timing must remain data-driven.

---

# 8. Main Character Layer Findings

The Craftpix source already provides useful separated layers/variants, including concepts equivalent to:

```text
shadow
body
head
sword_back
sword_front
swing
red / damage overlay
with_shadow
without_shadow
```

This is valuable because it confirms the feasibility of the layered character design.

However DEV-R001 must **not immediately build the final equipment system**.

Use the source layers only to validate:

1. same frame geometry;
2. same animation timing;
3. front/back weapon occlusion;
4. stable alignment;
5. independent shadow feasibility.

---

# 9. Shadow Strategy — Review, Not Locked

Craftpix provides both:

```text
*_with_shadow.png
```

and separate/no-shadow material.

For the first test implement a switchable comparison:

```text
Mode A = original with_shadow sheet
Mode B = without_shadow + separate shadow layer
```

Do not permanently choose one approach before visual comparison.

Expected long-term direction is likely separate shadow because it is more flexible, but this handoff does not lock that decision.

---

# 10. Character Anchor / Pivot

Do **not** reuse the provisional DEV-004 anchor `(32,48)` as a fact.

DEV-004 used a generated validation dummy, not this Craftpix character.

For DEV-R001:

1. inspect Craftpix frames;
2. determine the stable world/root position from the original source;
3. measure foot baseline and visual center;
4. keep the source frames unmodified during measurement;
5. document the resulting pivot/anchor.

Important invariant:

```text
same world/root position across frames
```

Do not auto-center each frame using opaque bounding boxes.

Do not independently trim every frame.

Do not modify source frame positions simply because different poses have different opaque bounds.

The source animation already appears spatially coherent; preserve that coherence first.

---

# 11. Character Collision

Collision is not derived from the full 64×64 frame.

Use a small gameplay footprint around the feet.

For this pass, collision dimensions remain:

```text
TBD through runtime testing
```

Codex may propose a capsule/rectangle after inspecting the visible body and feet, but must document the chosen values as provisional.

Collision must stay stable across Idle / Walk / Run / Attack / Hurt / Death.

Do not resize collision to match each pose.

---

# 12. Fauna Reference

For the first vertical slice, use **Boar** only.

Craftpix fauna differs from the human character baseline.

Observed fauna logical frame:

```text
32×32 px
```

Audited Boar source:

| State | Frame Size | Frames / Direction |
|---|---:|---:|
| Idle | 32×32 | 4 |
| Walk | 32×32 | 6 |
| Run | 32×32 | 5 |
| Attack | 32×32 | 5 |
| Hurt | 32×32 | 4 |
| Death | 32×32 | 6 |

Craftpix fauna direction order differs from the main character:

```text
Down
Up
Left
Right
```

Do not assume all asset categories share one row order.

Again, use explicit source mapping.

Fauna timing observed in the audited source is commonly:

```text
150 ms/frame
```

DEV-R001 only needs Boar Idle/Walk initially unless Attack is useful for preview.

Do not implement AI/combat behavior yet.

---

# 13. Environment / Tile Reference

## 13.1 Roads

Source:

```text
Tile/Path and Road/Roads.tmx
```

Tiled source grid:

```text
16×16 px
```

Verified road sheets include:

```text
Road1_grass  = 240×416 = 15×26 source tiles
Road2_grass  = 240×416 = 15×26
Road3_grass  = 240×480 = 15×30
Road4_grass  = 240×480 = 15×30
Road5_grass  = 240×416 = 15×26

Ground_grass = 272×496 = 17×31
```

For DEV-R001, do not rebuild the full Roads.tmx map.

Use only enough road/ground tiles to create a small readable test patch.

The purpose is to test scale and style relationship with the 64×64 character.

---

# 14. Flora Reference

Craftpix tree source is **not one uniform tile-size family**.

The source includes individual sprites at multiple dimensions such as:

```text
16×16
32×32
48×48
64×64
128×128
```

Examples from the audit:

```text
Broken_tree6 = 16×16
Broken_tree2 = 32×32
Broken_tree3 = 48×48
Tree3        = 64×64
Tree1        = 128×128
```

There are also parallel variants such as:

```text
Trees
Trees_shadow
Trees_texture_shadow
Trees_texture_shadow_dark
```

Do not force every tree into a 32×32 or 64×64 box.

For the first vertical slice use **one 64×64 tree and one 128×128 tree** if practical, so the scene proves variable-size environmental sprites.

Tree collision should use trunk/root footprint only, not canopy bounds.

---

# 15. Farm / Packed Atlas Warning

Files such as:

```text
Farm/Supplies.png
Farm/Plants.png
```

are packed/irregular atlases without a supplied TMX mapping in the current folder.

Do not guess slicing coordinates from overall PNG dimensions.

Do not use them in DEV-R001 unless mapping is explicitly established.

Mark them as deferred.

---

# 16. Home TMX Warning

The source contains:

```text
Exterior.tmx
Exterior — копия.tmx
Interior1.tmx
```

Use `Exterior.tmx` as the safer initial exterior reference.

The copied file (`Exterior — копия.tmx`) contains additional helper/external references that are not clearly present in the current uploaded folder.

Do not make the copy file the baseline unless the missing references are intentionally restored.

---

# 17. Reset Scope in the Existing Repository

Before deleting anything, Codex must inventory the current repo and record it in the work log.

The current repository contains old prototype implementation under areas such as:

```text
scenes/dev/
scenes/interactables/
scenes/main/
scenes/npc/
scenes/player/
scenes/ui/
scenes/world/

systems/character_visual/
systems/interaction/

data/character_visual/
data/npc/

art/prototype/

tests/
```

These were created by DEV-001..004 and may be reset if tied to the obsolete prototype.

## Keep

Keep unless there is a concrete reason not to:

```text
.git history
docs/handoff/ historical files
addons/
Godot MCP / editor integration
icon.svg
project.godot renderer/viewport settings that remain valid
```

## Remove / replace

Remove or replace old DEV-001..004 implementation that no longer serves the new baseline.

This likely includes:

```text
old generated prototype art
DEV-004 generated character dummy
old DEV-004 validation manifests
old character_visual prototype system
old village placeholder scene
old placeholder NPC/interactable implementation
old prototype-specific tests/screenshots where no longer relevant
```

Do not mechanically delete an entire directory if a file is still a useful neutral project utility.

Audit first.

---

# 18. Git Safety Rule

Before reset:

```text
git status
```

must be reviewed.

Do not discard unrelated user changes.

Recommended workflow:

```text
1. confirm current branch
2. confirm clean/known working tree
3. make reset changes in a new normal commit
4. preserve previous commits as history
```

No force push.

No destructive history rewrite.

If the worktree contains uncommitted user changes that cannot be confidently categorized, stop and report.

---

# 19. Proposed Clean Runtime Structure

After cleanup, prefer a small understandable structure.

Example:

```text
res://
  art/
    vendor/
      craftpix/
        main_character/
          male/
        fauna/
          hunt_animal/
        flora/
          tree/
        tile/
          path_and_road/

  scenes/
    main/
    player/
    world/
    fauna/
    dev/

  systems/
    animation/

  data/
    source_mapping/

  tests/

  docs/
    handoff/
```

The exact directory names may be adapted if the repo already has a clean equivalent.

Important:

> Original Craftpix source files should remain identifiable as vendor/source assets and should not be silently modified in place.

If normalized runtime derivatives are created, keep them separate from originals.

---

# 20. Asset Provenance / License Rule

Do not assume an uploaded third-party asset is automatically cleared for every distribution use simply because it is present in Drive.

Keep provenance identifiable.

ART-002 remains the place to record source/license status.

DEV-R001 may use the assets for development/testing as directed by the user, but do not label them as final commercial AEVORA assets unless the source/license status is confirmed.

Do not upload or redistribute the source outside the project workflow unnecessarily.

---

# 21. DEV-R001 First Playable Slice

Build only a small technical visual slice.

Minimum scene:

```text
TestWorld
├── Ground / small road patch
├── Tree64
├── Tree128
├── Player
└── BoarPreview
```

Optional debug UI:

```text
current player state
facing
source row
current frame
frame count
frame duration
FPS
player position
```

No NPC dialogue.

No farming system.

No inventory.

No economy.

No combat damage.

No quest system.

No physiology.

No world clock.

---

# 22. Player v2

Build a fresh Player scene around the real 64×64 Craftpix character.

Recommended conceptual structure:

```text
Player (CharacterBody2D)
├── CollisionShape2D
├── VisualRoot
│   └── AnimatedSprite2D / equivalent source player
└── Camera2D
```

For the very first pass, it is acceptable to use one full Craftpix sheet per state.

Do not prematurely build a complicated universal manifest framework.

First prove:

```text
Idle
Walk
Run
4 directions
source timing
64×64 cells
stable pivot
correct world scale
```

Then add sword-layer tests.

---

# 23. Movement State

First pass movement states:

```text
idle
walk
run
```

Required behavior:

```text
no input       → idle
movement input → walk
run input      → run
```

Run key may be a temporary test binding.

Movement speed values are not yet canonical.

Choose provisional values, expose them as variables, and report them.

Do not derive movement distance from animation FPS.

---

# 24. Four-Direction Facing

Movement can be diagonal at the physics level if desired.

Visual facing remains four-direction.

For diagonal input, use a deterministic facing-selection rule.

Do not allow direction to rapidly flicker between two rows.

Document the chosen priority rule.

Do not physically mirror Left to create Right in this first pass because the Craftpix source already provides both directions.

Use the supplied frames.

---

# 25. First Character Acceptance Test

The following must be visually checked:

```text
[ ] Idle Down
[ ] Idle Left
[ ] Idle Right
[ ] Idle Up

[ ] Walk Down
[ ] Walk Left
[ ] Walk Right
[ ] Walk Up

[ ] Run Down
[ ] Run Left
[ ] Run Right
[ ] Run Up
```

Verify:

```text
[ ] each state uses correct 64×64 cell
[ ] source row mapping correct
[ ] source frame count correct
[ ] source timing reproduced
[ ] no frame bleeding
[ ] no texture blur
[ ] player root does not teleport across state changes
[ ] visible feet remain spatially coherent
[ ] collision remains stable
```

---

# 26. Sword Composition Test

After Unarmed Idle/Walk/Run passes, add a **separate technical test** for sword composition.

Use the Craftpix parts/source where practical:

```text
sword_back
body
sword_front
head
```

Goal:

- prove front/back occlusion;
- prove all layers use the same frame;
- prove source alignment is preserved.

Do not build full inventory/equipment ownership yet.

The test can simply toggle:

```text
Unarmed
Sword
```

---

# 27. Sword Attack Test

Only after layered sword Idle/Walk/Run is stable:

Test:

```text
Sword Attack = 8 frames
```

with the original 64×64 frames and source timing.

Also inspect `swing` effect layering.

Attack is visual-only in this handoff.

No hitbox/damage/stamina system yet.

---

# 28. Hurt / Death

Hurt and Death are lower priority than movement but can be added after movement + sword layering passes.

Use source counts:

```text
Hurt  = 5
Death = 7
```

Death should preserve the source's longer ending hold when present.

Do not add respawn/death gameplay logic.

---

# 29. Tool State

The current audited Main Character source does **not** provide the required general AEVORA Tool animation family.

Therefore:

```text
Tool = missing source / deferred
```

Do not invent a tool animation.

Do not generate one with AI during DEV-R001.

Record the gap.

We can source or design tool animations later.

---

# 30. Boar Preview

Boar is used only to compare scale and source conventions.

First pass:

```text
Idle
Walk
```

Optional:

```text
Run
```

No AI required.

The Boar can remain stationary or move on a simple scripted loop for preview.

Do not implement combat AI.

The important observation is whether:

```text
64×64 human character
vs
32×32 fauna frame
```

feels visually coherent in the same world.

Report the result rather than forcing a scale change.

---

# 31. Environment Slice

Use:

- one simple ground tile area;
- a short road segment;
- one 64×64 tree;
- one 128×128 tree.

This is enough to evaluate:

```text
character scale
road width impression
tree scale
camera framing
visual density
pixel filtering
```

Do not recreate the full village.

---

# 32. Pixel Rendering

For the first source-faithful test:

```text
nearest-neighbor / pixel-safe filtering
integer-aligned positioning where practical
no arbitrary smoothing
no source resampling
```

However ART-001 still treats final rendering richness/filter rules as subject to real-asset Godot testing.

Therefore Codex must capture evidence.

If another import setting visibly improves source fidelity without causing blur/jitter, report it rather than silently locking it.

---

# 33. TMX Usage

The `.tmx` files are important as **mapping evidence**.

DEV-R001 does not require importing entire Tiled maps into Godot.

Codex may parse/use TMX data to understand:

```text
source image dimensions
tile size
frame sequence
frame duration
layers
```

For the first runtime slice, it is acceptable to build Godot resources manually from the verified mapping.

Avoid introducing a third-party Tiled importer dependency unless there is a concrete benefit and the user approves it.

---

# 34. Do Not Repeat Old DEV-004 Architecture Automatically

DEV-004 used:

```text
JSON manifest loader
generated dummy atlas
custom character visual validation harness
```

Those were useful experiments but are not automatically the new production architecture.

DEV-R001 starts simpler.

Preferred progression:

```text
real source asset
→ faithful Godot playback
→ measure
→ validate
→ only then abstract reusable animation architecture
```

Do not rebuild a generic system before proving what the real assets actually require.

---

# 35. What Must Be Measured During the Test

Record actual measurements/findings for the Main Character:

```text
frame = 64×64 (locked)
visible body bounding range by state/direction
foot baseline
best world/pivot point
recommended collision footprint
visual height
visual width
road/character scale relationship
tree/character scale relationship
camera readability at 640×360
```

For any measurement that changes by pose, do not average blindly.

The goal is to find stable gameplay references, not normalize the art destructively.

---

# 36. Debug Overlay

Provide a lightweight toggleable debug view.

Useful overlays:

```text
64×64 frame boundary
player root/pivot crosshair
collision shape
current facing
state/frame
optional foot baseline
```

Debug guides must not affect sprite positioning.

---

# 37. Automated Tests

Keep automated tests small and directly relevant.

Minimum recommended tests:

### Asset geometry test

Verify known source dimensions:

```text
Unarmed Walk = 384×256
Unarmed Run  = 512×256
Unarmed Idle = 768×256
```

and that dimensions divide into 64×64 frames correctly.

### Frame count test

Verify:

```text
Walk = 6
Run  = 8
Idle = 12
```

### Direction mapping test

Verify:

```text
Down / Left / Right / Up
```

maps to the correct source rows.

### Scene smoke test

Verify the clean main scene and player instantiate without parser/runtime errors.

Do not recreate every old DEV-003/004 test unless it still represents the new implementation.

---

# 38. Required Screenshots

At minimum capture:

1. Player Idle Down in environment;
2. Player Walk side direction;
3. Player Run;
4. comparison with Boar;
5. environment scale with 64×64 and 128×128 trees;
6. debug frame/pivot/collision overlay;
7. sword layering if completed.

The screenshots should show actual game scale, not only zoomed sprite inspection.

---

# 39. Stop Conditions

Stop and report instead of guessing if:

- a required PNG referenced by the chosen TMX cannot be located;
- dimensions differ from the audited ART-002 values;
- source row order appears inconsistent with the audit;
- source frame alignment appears corrupted;
- a Craftpix layer cannot be reconstructed without missing files;
- imported PNG becomes blurry despite pixel-safe settings;
- the clean reset would delete unrelated user work;
- the current Git working tree contains ambiguous uncommitted work;
- commercial/source license status becomes a blocker for committing the assets.

Do not silently create replacement art.

---

# 40. Work Log Reset

Do not erase old `WORKLOG.md` history without preserving it.

Preferred options:

```text
A. archive old worklog to docs/history/
   then create a new current WORKLOG.md

or

B. keep one WORKLOG.md
   and add a clear:
   "DEV-R001 Restart Baseline v2"
   section
```

The current entry must state:

```text
DEV-001..004 runtime outputs superseded by DEV-R001
```

---

# 41. Definition of Done

DEV-R001 is complete when:

```text
[PASS] old prototype runtime has been safely reset/replaced
[PASS] Git history remains intact
[PASS] project opens cleanly in Godot
[PASS] Compatibility renderer retained
[PASS] 640×360 logical viewport works
[PASS] real Craftpix Main Character is used
[PASS] standard human frame is 64×64
[PASS] source row order is mapped correctly
[PASS] Idle 12 works in four directions
[PASS] Walk 6 works in four directions
[PASS] Run 8 works in four directions
[PASS] original source timing is reproduced
[PASS] no frame bleed / blur
[PASS] stable player world root/pivot is measured and documented
[PASS] provisional collision is documented
[PASS] a small road/ground environment exists
[PASS] 64×64 and 128×128 tree scale can be reviewed
[PASS] Boar scale can be reviewed
[PASS] screenshots are produced
[PASS] automated geometry/mapping smoke tests pass
[PASS] WORKLOG updated
```

Sword layer testing may be completed in the same handoff if cleanly achievable, but it must not block the core unarmed movement baseline.

---

# 42. Required Final Report From Codex

At completion report:

1. commit SHA;
2. files removed from the old prototype;
3. files preserved and why;
4. files added;
5. exact Craftpix PNG files used;
6. exact source frame mappings used;
7. measured Main Character pivot/ground anchor;
8. measured/provisional player collision;
9. movement speed values used for the test;
10. source timing actually implemented;
11. filtering/import settings;
12. visual scale observations;
13. Boar-to-player scale observation;
14. tree-to-player scale observation;
15. any source files that appear missing or ambiguous;
16. tests executed and results;
17. screenshot paths;
18. recommendations for the next handoff.

Do not silently modify ART-001 or ART-002 values from inside the codebase.

If implementation evidence suggests a design change, report it for review first.

---

# 43. Next Handoff After DEV-R001

Do not continue automatically.

After DEV-R001 we will visually review:

```text
character scale
animation quality
pivot
movement feel
roads
trees
fauna
```

Only after approval will the next handoff decide whether to focus on:

```text
character architecture / equipment
world tiles and terrain
fauna
home/environment
```

DEV-R001 is intentionally a **clean, source-faithful restart**, not the beginning of feature accumulation.

---

# Final Instruction to Codex

Start from the real audited assets.

Do not recreate the old generated prototype.

Do not "improve" Craftpix source art during the first pass.

Do not normalize animation frames destructively.

Do not assume all categories have the same frame size or direction order.

Use:

```text
Human Character = 64×64 frame
Boar/Fauna source = 32×32 frame
Road source tiles = 16×16
Trees = variable sprite dimensions
```

The first goal is not to make more systems.

The first goal is to establish **correct scale, correct mapping, correct animation playback, and a trustworthy Godot baseline** from which AEVORA can be rebuilt.
