# DEV-R001.2 — Direction Input, 1280×720 Display Review & Fence Collision Tuning

**AEVORA • Godot 4 • Craftpix Asset-First Baseline**

Status: **Implementation handoff — focused corrective pass (Revised: Walk/Run Attack enabled for prototype)**  
Current repository HEAD reviewed: `901e249d0f23371ba222a4c8e66cf43187b77e3c`  
DEV-R001.1 implementation commit: `b6c2a90ae3cd886416c2bc4d2f1b1d28d05be4b5`

---

# 1. Purpose

DEV-R001.2 is a small corrective pass.

Do not expand game systems.

Fix only:

1. keyboard direction controls must support the **Arrow keys** (`↑ ← ↓ →`) instead of requiring WASD;
2. player-facing control legend must show Arrow keys as the primary movement/direction input;
3. Godot visual simulation/review must be presented at **1280×720 laptop display size**;
4. fence collision must be tuned to the actual Craftpix fence geometry:
   - left/right side collision currently stops too early toward the bottom;
   - top fence collision currently extends slightly too far on the outer left/right ends;
5. Sword Walk Attack and Sword Run Attack remain deferred.

Preserve the working DEV-R001 / DEV-R001.1 character foundation.

---

# 2. Preserve Existing Character Contract

Do not change:

```text
Human frame       = 64×64
Source directions = Down / Left / Right / Up
Player pivot      = (32,44)
Player collider   = 10×6
Walk speed        = 48 px/s provisional
Run speed         = 112 px/s provisional
Sword Attack      = 8 frames × 150 ms
```

Do not resize, recenter, crop, or otherwise normalize the Craftpix character frames.

Idle / Walk / Run / Sword Attack must remain source-faithful.

---

# 3. Arrow Keys — Required Movement Input

The current `project.godot` maps movement only to:

```text
W
A
S
D
```

This is incomplete for the requested playtest.

Existing semantic actions must remain:

```text
move_up
move_left
move_down
move_right
```

Add physical Arrow-key events:

```text
move_up    → Up Arrow
move_left  → Left Arrow
move_down  → Down Arrow
move_right → Right Arrow
```

The Player controller must continue to read semantic actions:

```gdscript
Input.get_vector(
    "move_left",
    "move_right",
    "move_up",
    "move_down"
)
```

Do not add direct `KEY_UP`, `KEY_LEFT`, etc. checks to player movement logic.

---

# 4. WASD Compatibility

For DEV-R001.2:

```text
Arrow keys = primary player-facing movement/direction control
```

WASD may remain as a secondary development alias so existing automated tests and developer ergonomics do not needlessly break.

However the normal control legend must no longer present WASD as the primary control.

If retaining WASD causes ambiguity, keep it in the Input Map but omit it from the normal legend.

Expected behavior:

```text
↑ = move + face Up
↓ = move + face Down
← = move + face Left
→ = move + face Right
```

Diagonal combinations of Arrow keys may continue to use the existing deterministic facing rule.

---

# 5. Updated Control Legend

Replace:

```text
WASD  Move / Direction
```

with:

```text
↑ ↓ ← →  Move / Direction
```

Suggested full legend:

```text
↑ ↓ ← →  Move / Direction
Shift     Run
Tab       Equip / Unequip Sword
LMB / J   Attack
F1        Debug Info
F2        Debug Guides
F3        Shadow Compare
```

Do not restore `B`.

The Boar remains autonomous ambient presentation.

---

# 6. 1280×720 Visual Simulation — Important Distinction

The current project already uses:

```text
logical viewport = 640×360
window override  = 1280×720
integer scaling  = 2×
```

This is a valid pixel-art arrangement.

For this pass, **do not change the logical viewport to 1280×720**.

Changing the logical viewport would double the visible world area and alter the apparent character/environment scale.

Instead, the required review configuration is:

```text
internal logical simulation = 640×360
actual laptop/game window    = 1280×720
display scale                = exact integer 2×
```

This preserves the approved 64×64 source assets and existing world composition.

---

# 7. 1280×720 Capture Requirement

DEV-R001.1 documentation captured internal 640×360 viewport images.

DEV-R001.2 must additionally capture the **actual displayed 1280×720 result**.

Preferred:

```text
Godot game window running at 1280×720
→ capture actual rendered window through Godot MCP / desktop capture
```

If a test script only reads the internal viewport texture, it will naturally return 640×360 and does not satisfy this display-review requirement.

Do not change asset scale merely to make a 1280×720 screenshot.

Required evidence:

```text
docs/screenshots/dev-r001-2-display-1280x720.png
```

or an equivalent clearly named path.

The screenshot must be exactly 1280×720.

---

# 8. Sword Walk / Run Attack — Implement in Prototype

The user has confirmed the current Craftpix assets are **official free assets downloaded from Craftpix** and this project is still in prototype/testing.

For this prototype, Sword Walk Attack and Sword Run Attack may be implemented.

Important compliance rule:

```text
Prototype use now
→ log source/provenance/license
→ preserve replacement requirement
→ before public/commercial release:
   clear the asset for final use OR replace it with legal final artwork
```

Do not delete this provenance later.

The project-level replacement/compliance ledger is maintained in:

```text
ART-002 → 11 License & Replacement Ledger
```

This implementation permission is a **prototype project decision**, not a statement that every future distribution use is automatically cleared.

---

## 8.1 Verified source files

The following official Craftpix files are present in the uploaded Drive source.

### Sword Walk Attack

```text
Sword_Walk_Attack_with_shadow.png
Sword_Walk_Attack_without_shadow.png
Sword_Walk_Attack2_sword_back.png
Sword_Walk_Attack3_body.png
Sword_Walk_Attack4_sword_front.png
Sword_Walk_Attack5_head.png
Sword_Walk_Attack6_swing.png
```

Verified geometry:

```text
sheet size       = 384×256
logical frame    = 64×64
columns          = 6
direction rows   = 4
frames/direction = 6
```

### Sword Run Attack

```text
Sword_Run_Attack_with_shadow.png
Sword_Run_Attack_without_shadow.png
Sword_Run_Attack2_sword_back.png
Sword_Run_Attack3_body.png
Sword_Run_Attack4_sword_front.png
Sword_Run_Attack5_head.png
Sword_Run_Attack6_swing.png
```

Verified geometry:

```text
sheet size       = 512×256
logical frame    = 64×64
columns          = 8
direction rows   = 4
frames/direction = 8
```

Preserve the existing Craftpix human source direction mapping:

```text
row 0 = Down
row 1 = Left
row 2 = Right
row 3 = Up
```

ART-002 source audit records 150 ms/frame for these states. Use that source timing for the first implementation unless direct source evidence proves otherwise.

Therefore:

```text
Walk Attack total duration = 6 × 150 ms = 0.9 s
Run Attack total duration  = 8 × 150 ms = 1.2 s
```

---

## 8.2 Source import rule

Import the original files unchanged into the existing vendor path:

```text
art/vendor/craftpix/main_character/male/
```

Do not:

- resize;
- crop;
- shift;
- repaint;
- rename source pixels into a derived atlas;
- reorder source rows;
- generate missing replacements.

Record all imported files in the existing provenance/audit workflow.

---

## 8.3 Attack state selection

When Sword is equipped, `attack_primary` selects the attack family from the locomotion state at the moment the input begins:

```text
Idle + Attack
→ attack
→ Sword Attack 8F

Walk + Attack
→ walk_attack
→ Sword Walk Attack 6F

Run + Attack
→ run_attack
→ Sword Run Attack 8F
```

Use semantic state names in mapping/code:

```text
attack
walk_attack
run_attack
```

Do not infer the animation only from filenames throughout Player code.

---

## 8.4 Moving attack root behavior

Standing Sword Attack keeps the existing DEV-R001.1 behavior:

```text
attack
→ root movement stopped during one-shot
```

For the new moving attacks:

```text
walk_attack
→ continue root translation at walk speed

run_attack
→ continue root translation at run speed
```

For this prototype pass, capture the movement direction when the attack begins.

During the one-shot:

```text
attack facing = locked
movement direction = locked
attack speed class = locked
```

This avoids visual mismatch between a left-facing attack animation and a root that suddenly steers up/right.

Example:

```text
holding → + Walk + Attack
→ start walk_attack facing Right
→ continue moving Right at walk_speed
→ ignore steering changes until animation completes
→ then resume current live input
```

Likewise:

```text
holding ↑ + Shift + Attack
→ start run_attack facing Up
→ continue Up at run_speed
→ finish
→ resume current live input
```

This lock is a **prototype technical rule**, not the final combat-control design.

Collision still applies through `move_and_slide()`.

If the character reaches a wall/fence/tree during a moving attack:

```text
root is blocked naturally
animation still completes
```

Do not teleport through collision to preserve theoretical attack distance.

---

## 8.5 Moving attack distance is provisional

At current provisional movement speeds and source timing:

```text
Walk Attack:
48 px/s × 0.9 s ≈ 43.2 px maximum unobstructed travel

Run Attack:
112 px/s × 1.2 s ≈ 134.4 px maximum unobstructed travel
```

These are **test results implied by current speed + source duration**, not locked combat design values.

Codex must report whether these distances feel visually coherent at the 1280×720 display review.

Do not silently retune movement speed or source timing in this handoff.

If Run Attack travels too far, report it for the next design decision.

---

## 8.6 Layer composition

Both moving attack families must use their supplied layers.

Expected conceptual order:

```text
shadow
sword_back
body
sword_front
head
swing
```

However DEV-R001.1 already proved that the standing Sword Attack contains at least one pose-specific layer-order discrepancy in the vendor source.

Therefore:

> do not assume one layer order reproduces every Walk/Run Attack pose perfectly.

For every direction/frame:

1. composite the separated source layers;
2. compare against the corresponding `*_with_shadow.png` and/or `*_without_shadow.png`;
3. if a source-pixel discrepancy exists, inspect it;
4. add the smallest **data-driven pose-specific layer override** required;
5. do not edit source PNGs.

The validation target is source-faithful reconstruction within the same tolerance already used by DEV-R001.1.

---

## 8.7 Non-loop behavior

Treat all three sword attack families as one-shot actions:

```text
attack      loop = false
walk_attack loop = false
run_attack  loop = false
```

`SourceSprite` must:

```text
advance from frame 0 to final frame
hold each source duration
not wrap final frame to 0
emit animation_finished(state) once
```

Do not emit completion repeatedly while sitting on the last frame.

---

## 8.8 Attack input precedence

Suggested Player order:

```text
read movement axis
determine locomotion class
if sword && attack_primary && not attacking:
    choose attack / walk_attack / run_attack
    capture attack direction and movement vector
    start one-shot
```

During an active attack:

```text
additional attack_primary → ignored
Tab                         → ignored
```

No combo queue yet.

No animation restart spam.

---

## 8.9 Attack completion

When any sword attack completes:

```text
attack
walk_attack
run_attack
```

the Player must immediately reevaluate current live input.

Examples:

```text
Walk Attack finishes
user still holds →
→ normal Walk Right
```

```text
Run Attack finishes
user released all direction input
→ Sword Idle
```

```text
Run Attack finishes
user now holds ← without Shift
→ Sword Walk Left
```

Do not force a return to the locomotion state that existed at attack start.

---

## 8.10 No gameplay damage yet

Even though moving attack animations are now implemented, this handoff still does **not** add:

```text
damage
hitbox
hurtbox
stamina
enemy HP
knockback
combo system
weapon stats
```

The new states are visual/movement/action validation only.

---

# 9. Fence Collision — Current Bug

Current code classifies a fence cell as a vertical side only with:

```gdscript
var side: bool = cell.at.y > -2 and cell.at.y < 6
```

and uses:

```text
side collider       = 6×16, offset (0,-8)
horizontal collider = 16×4, offset (0,-2)
```

This creates a real geometry problem at the lower left/right corners.

From `Exterior.tmx` Fence layer (ID 24), audited source topology is:

```text
Top row y=-2:
x=-12 ... x=1

Left side:
x=-12, y=-1 ... 5

Right side:
x=1, y=-1 ... 5

Bottom row y=6:
x=-12 ... x=1

Open gate:
x=-4 and x=-3 at y=6
```

Relevant GIDs:

```text
802 = top-left corner
803 = top horizontal rail
804 = top-right corner

819 = left vertical side
821 = right vertical side

836 = bottom-left corner
837 = bottom horizontal rail
838 = bottom-right corner

788,789 = open gate / non-blocking
```

---

# 10. Why the Side Fence Can Be Crossed Near the Bottom

With the current formula:

Last vertical side segment at `y=5` spans approximately:

```text
Y 336 .. 352
```

The bottom horizontal rail at `y=6` spans approximately:

```text
Y 364 .. 368
```

This leaves roughly:

```text
12 px collision gap
```

between the side wall and the bottom corner/rail.

That is large enough for the player's 10×6 feet collider to slip through.

This matches the observed playtest issue.

---

# 11. Fence Collider Strategy — Replace Coordinate Heuristic

Do not continue using:

```gdscript
if y is in this numeric range → side
else → horizontal
```

for Craftpix fence collision.

Use explicit fence-piece profiles based on the source GID/topology.

Recommended source-specific collision profiles:

```text
GID 802  top-left cap
GID 803  top rail
GID 804  top-right cap

GID 819  left side
GID 821  right side

GID 836  bottom-left corner
GID 837  bottom rail
GID 838  bottom-right corner

GID 788  gate = no collision
GID 789  gate = no collision
```

Store these profiles in source mapping/configuration where practical instead of scattering raw GIDs through gameplay logic.

---

# 12. Bottom Corner Fix

Bottom corner cells must join the vertical side and horizontal bottom rail continuously.

For:

```text
836 = bottom-left
838 = bottom-right
```

use a **composite collision**:

```text
vertical component
+
horizontal component
```

The vertical component should bridge from the previous side cell through the bottom-corner tile.

Using the existing tile coordinate convention, a vertical component equivalent to:

```text
size   ≈ 6×16
offset ≈ (0,-8)
```

on the bottom corner fills the current side-to-bottom gap.

Keep the horizontal bottom rail collision as well.

Result:

```text
vertical side
│
│
├──── bottom rail
```

must be continuous at both corners.

No gap large enough for the player collider may remain.

---

# 13. Top Fence Outer Ends Are Too Long

The current top row gives every cell a full:

```text
16×4
```

horizontal collision.

That means the outer corner cells:

```text
802 top-left
804 top-right
```

block the complete 16 px tile width even if the visible wooden rail/cap does not occupy that full horizontal span.

The user observed the collision extending slightly too far:

```text
left outer end  ← too long
right outer end → too long
```

Do not fix this by shrinking every top-rail collider.

Interior top rail:

```text
803
```

may continue to use the normal full rail span if it matches the source.

Only tune the two cap/corner profiles independently.

---

# 14. Measure Top Corner Visual Bounds

Before choosing final widths for GID 802 / 804:

1. extract/read the corresponding 16×16 region from `exterior.png`;
2. inspect the opaque pixels that actually represent the fence base/rail;
3. determine the intended collision span;
4. use an integer-pixel collider aligned to that visual base;
5. optionally leave ~1 px visual tolerance if needed for comfortable movement.

This is a **one-time source measurement**.

Do not dynamically create gameplay collision from alpha every frame/runtime.

Record the measured values in the DEV-R001.2 report.

Expected profile concept:

```text
802:
  width < 16
  shifted inward from the outer-left edge

804:
  width < 16
  shifted inward from the outer-right edge
```

Do not assume both need an arbitrary 12 px width without measuring the source first.

---

# 15. Bottom Rail and Gate

Bottom rail:

```text
837
```

should retain continuous horizontal collision.

Gate pieces:

```text
788
789
```

must remain non-blocking.

Do not fix side leakage by placing one large rectangle across the whole bottom fence, because that would close the intended gate.

---

# 16. Fence Collision Data Structure

Preferred mapping example:

```json
"fence_collision_profiles": {
  "802": {"type": "top_left_cap"},
  "803": {"type": "top_rail"},
  "804": {"type": "top_right_cap"},
  "819": {"type": "left_side"},
  "821": {"type": "right_side"},
  "836": {"type": "bottom_left_corner"},
  "837": {"type": "bottom_rail"},
  "838": {"type": "bottom_right_corner"},
  "788": {"type": "gate_open"},
  "789": {"type": "gate_open"}
}
```

The exact schema may stay smaller if a clean equivalent already exists.

The important point is:

> source tile type determines collision profile, not only cell Y coordinate.

---

# 17. Fence Debug Visualization

F2 must continue showing collision shapes.

For fence review, make it easy to see:

- top-left outer end;
- top-right outer end;
- entire left side;
- entire right side;
- bottom-left connection;
- bottom-right connection;
- open gate.

Do not alter fence sprite placement while tuning physics.

Only collision geometry should change.

---

# 18. Fence Traversal Tests

Add targeted physics tests.

## Left side

Attempt player movement through the left fence at:

```text
upper section
middle section
lower section near bottom-left corner
```

All must block.

## Right side

Same:

```text
upper
middle
lower near bottom-right corner
```

All must block.

## Bottom corners

Specifically try diagonal movement through the old side/bottom seam.

Must block.

## Gate

Move through the intended 32 px open gate.

Must remain passable in both directions.

## Top outer ends

Approach just outside the visible extreme top-left/top-right caps.

Player must not be blocked by invisible excess collision.

Approach the visible fence itself.

Player must be blocked.

---

# 19. Player Input Tests

Automated test must verify:

```text
Up Arrow    triggers move_up
Down Arrow  triggers move_down
Left Arrow  triggers move_left
Right Arrow triggers move_right
```

Also verify facing changes correctly.

If WASD is retained as secondary input, verify it does not interfere with Arrow input.

---

# 20. Display Tests

Verify project configuration still states:

```text
viewport 640×360
window 1280×720
integer scale
```

Then verify the actual review window is 1280×720.

Do not call an internal 640×360 image a 1280×720 display capture.

---

# 21. Required Visual Captures

Produce:

```text
dev-r001-2-display-1280x720.png
dev-r001-2-fence-collision.png
```

The fence collision capture should have F2 enabled and clearly show:

- shortened top outer ends;
- continuous left/right lower corners;
- open gate.

Optional:

```text
dev-r001-2-arrow-input.png
```

with debug info showing actual direction/facing while Arrow keys are used.

---

# 22. Scope — Do Not Expand

This handoff **does include**:

```text
Sword Walk Attack
Sword Run Attack
```

using the verified official Craftpix prototype source.

Do not add:

- combat hitboxes;
- health;
- damage;
- stamina;
- combo systems;
- inventory;
- NPC;
- new fauna;
- new houses;
- map expansion;
- new art generation.

This remains a correction/tuning and animation-validation pass.

---

# 23. Acceptance Criteria

DEV-R001.2 is complete when:

```text
[PASS] Up/Down/Left/Right Arrow keys control movement
[PASS] Arrow keys change facing correctly
[PASS] player-facing legend uses arrow symbols instead of WASD
[PASS] semantic move actions remain in use
[PASS] actual Godot review window is 1280×720
[PASS] logical 640×360 pixel-art viewport is preserved
[PASS] 1280×720 display screenshot is produced

[PASS] left fence side cannot be crossed at lower end
[PASS] right fence side cannot be crossed at lower end
[PASS] bottom-left corner collision is continuous
[PASS] bottom-right corner collision is continuous
[PASS] top-left collision no longer extends visibly too far
[PASS] top-right collision no longer extends visibly too far
[PASS] gate remains open/passable
[PASS] fence source pixels/placement remain untouched

[PASS] Idle/Walk/Run remain unchanged
[PASS] standing Sword Attack remains unchanged
[PASS] Sword Walk Attack uses 384×256 source / 64×64 cells / 6 frames / 4 directions
[PASS] Sword Run Attack uses 512×256 source / 64×64 cells / 8 frames / 4 directions
[PASS] Walk Attack and Run Attack use source 150 ms timing
[PASS] Walk Attack is one-shot/non-loop
[PASS] Run Attack is one-shot/non-loop
[PASS] attack state selection is Idle→Attack / Walk→Walk Attack / Run→Run Attack
[PASS] Walk Attack root moves at walk_speed with captured attack direction
[PASS] Run Attack root moves at run_speed with captured attack direction
[PASS] moving attacks respect environment collision
[PASS] moving attacks finish once and return to current live input
[PASS] separated Walk/Run Attack layers reconstruct their full source sheets
[PASS] any pose-specific layer overrides are data-driven and documented
[PASS] pivot remains (32,44)
[PASS] player collider remains 10×6
[PASS] Boar ambient behavior remains unchanged
[PASS] F1/F2/F3 remain functional
[PASS] prototype source/provenance/replacement status is recorded
[PASS] tests pass
[PASS] WORKLOG updated
```

---

# 24. Required Codex Report

Report:

1. commit SHA;
2. exact Arrow-key Input Map changes;
3. whether WASD was retained as secondary alias;
4. confirmation that the normal legend now shows Arrow keys;
5. confirmation logical viewport remains 640×360;
6. confirmation review window/capture is 1280×720;
7. fence GID collision profile mapping;
8. measured collider bounds for GID 802 and 804;
9. final bottom-corner collision shapes for 836 and 838;
10. old gap measurement vs corrected gap;
11. fence traversal test results;
12. gate traversal result;
13. screenshots;
14. automated test counts/results;
15. exact Sword Walk Attack file list, mapping, timing and layer order;
16. exact Sword Run Attack file list, mapping, timing and layer order;
17. any pose-specific layer-order overrides discovered;
18. measured unobstructed Walk Attack travel distance;
19. measured unobstructed Run Attack travel distance;
20. collision behavior when a moving attack reaches fence/house/tree;
21. confirmation that Craftpix prototype provenance/replacement tracking remains recorded for pre-publish cleanup.

---

# 25. Final Instruction

Do not change visual art to solve collision.

Do not change character scale to solve display resolution.

Use only the verified official Craftpix prototype animation content that is actually present.

This pass should produce:

```text
Arrow-key playable controls
+
1280×720 laptop-display review
+
fence collision that follows the visible Craftpix geometry
+
standing / walking / running Sword Attack playback
```

while preserving the working DEV-R001.1 baseline.
