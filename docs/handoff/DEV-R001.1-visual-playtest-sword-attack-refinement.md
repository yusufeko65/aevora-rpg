# DEV-R001.1 — Visual Playtest & Sword Attack Refinement

**AEVORA • Godot 4 • Craftpix Asset-First Baseline**

Status: **Implementation handoff — refinement of DEV-R001**  
Parent baseline: **DEV-R001 / commit `c737e998ae61a28abffe40949feb0e413ff24fea`**

---

# 1. Purpose

DEV-R001 proved the source-faithful technical baseline:

- real Craftpix Main Character;
- 64×64 standard human sprite frame;
- source-faithful Idle / Walk / Run;
- four directions;
- stable pivot/root;
- fixed player collision;
- sword locomotion layers;
- one Boar source preview;
- native Craftpix road/tree assets;
- pixel-safe Godot rendering.

DEV-R001.1 must **refine the playtest experience without rebuilding the baseline**.

Primary goals:

1. replace the extremely sparse technical map with a small, readable Craftpix-based visual playtest area;
2. clarify the control legend;
3. remove the Boar debug toggle and fake automatic direction rotation;
4. make the Boar behave as a simple ambient moving creature;
5. add actual Sword Attack playback using the audited Craftpix source;
6. preserve all proven character mapping, scale, pivot, anchor, source timing, and collision behavior.

This remains a **visual and input validation pass**, not a gameplay/combat-system handoff.

---

# 2. Preserve DEV-R001 — Do Not Reset Again

DEV-R001 is now the valid technical baseline.

Do **not**:

- reset the project again;
- rebuild the 64×64 character system from scratch;
- replace Craftpix with generated sprites;
- change the measured player pivot just because new states are added;
- resize source PNGs;
- reorder source rows physically;
- recenter individual frames;
- change collision based on individual animation poses.

The following DEV-R001 values remain the starting contract:

```text
Human frame       = 64×64 px
Human source rows = Down / Left / Right / Up
Player pivot      = (32,44) provisional-but-working baseline
Player collider   = 10×6 fixed feet rectangle
Walk speed        = 48 px/s provisional
Run speed         = 112 px/s provisional
Viewport          = 640×360 logical
Display reference = 1280×720
Renderer          = Compatibility
```

Any proposed change to the pivot, collider, or frame contract must be reported with evidence instead of silently applied.

---

# 3. Current Problems to Fix

The current DEV-R001 scene is technically correct but visually too sparse:

```text
grass field
+ one short road
+ 2 trees
+ 1 player
+ 1 stationary Boar preview
```

The current help text is also development-oriented:

```text
WASD move
Shift run
Tab sword
F1 info
F2 guides
F3 shadow
B boar
```

Current Boar behavior is artificial:

- it stays at one world position;
- its facing direction changes automatically every ~3.6 seconds;
- `B` toggles `Idle ↔ Walk`;
- this is useful as a sprite-sheet preview, but not useful as a game-world visual test.

Current sword behavior only supports:

```text
Idle
Walk
Run
```

and does not expose Sword Attack even though the audited Craftpix source contains it.

---

# 4. Scope Boundary

DEV-R001.1 MAY implement:

- richer small visual test map;
- existing Craftpix Home/Exterior environment sources;
- additional trees/ground/path/fence/yard props;
- clean movement control legend;
- `attack_primary` input action;
- source-faithful Sword Attack animation;
- simple movement-state-aware sword attack selection if source assets are available;
- Boar ambient wandering;
- source-faithful Boar Idle/Walk;
- debug overlays and tests needed for these changes.

DEV-R001.1 MUST NOT implement:

- health;
- damage;
- enemy combat;
- hitboxes/hurtboxes;
- stamina;
- knockback;
- loot;
- death gameplay;
- inventory;
- equipment ownership;
- weapon stats;
- NPC AI;
- pathfinding/navigation mesh unless absolutely necessary for the simple Boar test;
- farming;
- clock;
- physiology;
- quests;
- dialogue;
- save/load.

Sword attack in this handoff is **animation/input validation only**.

---

# 5. Visual Map Refinement

## 5.1 Goal

The map should stop looking like an isolated sprite inspection board and start resembling a small coherent RPG environment.

It still does **not** need to be a complete village.

Target composition:

```text
────────────────────────────────
grass / vegetation variation

        trees / bushes

   ┌─────────────────┐
   │   small house   │
   └───────┬─────────┘
           │ yard
       fence / gate

────────── road/path ──────────

          player start

     tree             tree

              open field

                boar wander area
────────────────────────────────
```

The purpose is to evaluate:

- character-to-house scale;
- character-to-road scale;
- tree scale;
- map visual density;
- readable walkable space;
- Y-sort;
- collision;
- camera framing;
- source art compatibility.

---

# 6. Environment Source Priority

Prefer existing audited Craftpix source under:

```text
07 - Art & Visual/
  Main Character/
    Home/
  Flora/
    Tree/
  Tile/
    Path and Road/
```

Relevant audited Home source includes:

```text
Exterior.tmx
ground_grass_details.png
exterior.png
house_details.png
Smoke_animation.png
Doors_windows_animation.png
```

Use `Exterior.tmx` as the primary home/exterior reference.

Do **not** use `Exterior — копия.tmx` as the baseline because it contains additional helper/external references that were not clearly complete in the uploaded source.

Do not invent extraction coordinates for unknown packed assets.

If a required PNG referenced by `Exterior.tmx` is not available locally:

> stop that specific asset import and report the exact missing filename.

Do not generate or draw a replacement.

---

# 7. Minimum Visual Area Content

The new playtest area should contain at least:

```text
1 small house/exterior structure
1 main road/path section
1 yard/open dirt or ground transition area
1 short fence/gate composition if source mapping is clear
4+ trees total, mixing at least two source sizes
some grass/ground visual variation
1 player
1 Boar ambient creature
```

Optional if source mapping is unambiguous:

```text
small exterior props
window/door animation
smoke animation
decorative grass details
```

Do not add visual clutter merely to hit a count.

The scene should still have sufficient open room for Walk/Run/Attack testing.

---

# 8. World Geometry and Collision

Continue the current rule:

```text
visual bounds != collision bounds
```

For environment objects:

- tree collision = trunk/root footprint;
- house collision = building footprint/walls, not roof silhouette;
- fence collision = fence base/line;
- road = non-colliding terrain;
- decorative grass = non-colliding;
- canopy may visually overlap the player through Y-sort where appropriate.

Do not create one large collision rectangle around all visible environment art.

---

# 9. Y-Sort

The improved map must prove proper 3/4 top-down overlap.

The player must be able to:

- walk in front of a tree trunk/canopy boundary;
- walk behind appropriate environment visuals;
- pass near house/fence without visual sorting glitches.

Use Godot Y-sort or equivalent explicit layering.

Do not solve overlap by permanently forcing every object above/below the player regardless of position.

---

# 10. Controls — Player-Facing Legend

The current bottom legend must be changed.

Use a cleaner gameplay-oriented legend, for example:

```text
WASD  Move / Direction
Shift Run
Tab   Equip / Unequip Sword
LMB / J  Attack
F1    Debug Info
F2    Debug Guides
F3    Shadow Compare
```

Remove:

```text
B boar
```

from the legend and runtime input behavior.

`B` was only a development preview toggle and no longer has a useful player-facing purpose.

---

# 11. WASD Behavior

Keep current movement behavior:

```text
W = move + face Up
S = move + face Down
A = move + face Left
D = move + face Right
```

Do **not** change WASD into facing-only controls.

The requested refinement is to make the UI text clearly communicate:

```text
WASD = Move / Direction
```

rather than merely `WASD move`.

Diagonal movement may remain enabled.

Continue the current deterministic facing behavior unless testing shows a visible issue.

---

# 12. Input Map — Attack

Add a semantic input action:

```text
attack_primary
```

Development bindings:

```text
Left Mouse Button
J
```

The player code must use:

```text
Input.is_action_just_pressed("attack_primary")
```

or equivalent semantic action handling.

Do not hard-code keyboard key `J` directly into the player state logic.

This allows later rebinding/gamepad support without rewriting the character controller.

---

# 13. Sword Attack Source

The audited Craftpix Drive source contains the following Sword Attack files:

```text
Sword_attack_with_shadow.png
Sword_attack_without_shadow.png
Sword_attack2_sword_back.png
Sword_attack3_body.png
Sword_attack4_sword_front.png
Sword_attack5_head.png
Sword_attack6_swing.png
```

Primary attack source contract:

```text
logical frame = 64×64
directions    = Down / Left / Right / Up
frames        = 8 per direction
source timing = 150 ms/frame unless TMX evidence says otherwise
```

Codex must confirm the exact `Base_boy.tmx` sequence before runtime mapping.

Do not infer attack source columns solely from total PNG dimensions if TMX provides explicit sequencing.

If these files are not present in the local repo, import the original audited source through the approved project source workflow.

Do not create substitute attack art.

---

# 14. Sword Attack Layer Order

Reconstruct the attack using source layers in the correct order.

Expected conceptual composition:

```text
shadow
sword_back
body
sword_front
head
swing
```

However confirm the actual layer/order against `Base_boy.tmx` and source pixels.

The `swing` layer is an effect layer and may need to appear above body/weapon depending on the source.

Validate composition against the original full attack sprite where possible.

The final composite must not shift the player's root.

---

# 15. Attack State Model for This Pass

Add a temporary visual action state.

Minimum state flow:

```text
locomotion
   ↓ attack_primary
Sword Attack
   ↓ animation complete
return to valid locomotion state
```

For the first implementation:

- Attack is one-shot;
- Attack does not loop;
- Attack returns to Idle/Walk/Run depending on current input after completion;
- current facing is locked for the attack animation unless a strong implementation reason exists otherwise;
- no damage event is emitted;
- no hitbox is created.

Do not move the player root merely because the attack pose extends visually.

---

# 16. Attack and Movement

Preferred first behavior:

```text
Idle + Attack → Sword Attack
```

If the audited source files for these are available and clearly mapped:

```text
Walk + Attack → Sword Walk Attack
Run  + Attack → Sword Run Attack
```

they may also be implemented in DEV-R001.1.

Known audited counts:

```text
Sword Attack      = 8 frames
Sword Walk Attack = 6 frames
Sword Run Attack  = 8 frames
```

Important:

> Do not block the handoff if Walk Attack / Run Attack source files are not yet present locally.

Minimum required implementation is:

```text
Sword equipped + attack_primary
→ Sword Attack 8F
```

while standing or after movement input is temporarily suppressed during the one-shot.

Report any source gaps.

---

# 17. Unarmed Attack

The audited base character source does not currently provide an equivalent general unarmed attack source in the selected baseline.

Therefore:

```text
Unarmed + attack_primary
```

may do one of the following for DEV-R001.1:

```text
A. no animation, no-op;
or
B. small debug text: "Unarmed attack source not mapped"
```

Do not invent an unarmed animation.

Do not reuse Sword Attack without the sword.

---

# 18. Equip / Unequip Sword

Keep:

```text
Tab = Equip / Unequip Sword
```

as a development control.

When Sword is equipped:

```text
Idle → Sword Idle
Walk → Sword Walk
Run  → Sword Run
Attack → Sword Attack
```

When Sword is not equipped:

```text
Idle → Unarmed Idle
Walk → Unarmed Walk
Run  → Unarmed Run
```

Equipment ownership/inventory is not part of this handoff.

---

# 19. Attack Input During Existing Attack

Prevent animation restart spam.

If an attack is already playing:

```text
additional attack_primary input
→ ignored for this pass
```

Do not implement attack queueing/combos yet.

Do not restart frame 0 every mouse click.

---

# 20. Attack Completion

The animation player/source system currently loops all configured states.

Extend it carefully to support a non-loop state.

Required metadata or code behavior:

```text
loop = false
```

for Sword Attack.

At final frame:

```text
hold/finish
→ notify Player
→ return to locomotion
```

Do not globally change Idle/Walk/Run looping.

This is the smallest useful extension of the current `SourceSprite` architecture.

---

# 21. Preserve Pivot During Attack

Current Main Character pivot:

```text
(32,44)
```

works for DEV-R001 locomotion.

Test Sword Attack with the same world root.

Required:

```text
Player CharacterBody2D position remains unchanged
when switching:
Sword Idle → Sword Attack → Sword Idle
```

The visible weapon/swing may extend beyond the normal body silhouette.

That is allowed.

Do not:

- center the attack sprite by its opaque bounds;
- shift Player position to center the sword;
- scale the attack frame;
- trim each attack frame independently.

If source attack art appears misaligned with `(32,44)`, first compare it to the original Craftpix layer/full sheet.

Only report a pivot change if the **source itself** demonstrates a different intended ground root.

---

# 22. Boar — Remove Preview Behavior

Delete/replace the current behavior that performs:

```text
Down → Up → Left → Right
every ~3.6 seconds
```

while remaining stationary.

Also remove:

```text
B = Idle/Walk toggle
```

from `debug_overlay.gd`.

This old behavior served sprite inspection only.

---

# 23. Boar Ambient Wander

The Boar should now act like a minimal ambient creature.

This is **not full AI**.

Suggested simple state machine:

```text
IDLE
  wait 1.5–4 sec
      ↓
choose nearby target / direction
      ↓
WALK
  move for 1–3 sec or until local target reached
      ↓
IDLE
```

Facing must come from actual movement velocity:

```text
velocity.x > 0 → Right
velocity.x < 0 → Left
velocity.y > 0 → Down
velocity.y < 0 → Up
```

No independent facing timer.

The Boar should remain in a bounded test area.

A simple local rectangular roam region is sufficient.

Do not add NavigationServer/pathfinding unless the environment requires it.

---

# 24. Boar Collision

Add only what is needed for believable playtest behavior.

Recommended:

```text
small fixed body/footprint collision
```

The Boar may collide with major environment obstacles if simple.

It does not need to collide with or attack the player.

If avoiding trees/house would require a large AI/pathfinding scope, keep its roam zone in an unobstructed field for DEV-R001.1.

---

# 25. Boar States

Minimum:

```text
Idle
Walk
```

Optional:

```text
Run
```

Do not add Boar Attack/Hurt/Death gameplay in this handoff.

The goal is only to stop the source creature looking like a rotating sprite preview.

---

# 26. Debug Behavior

Keep useful debug controls:

```text
F1 Debug Info
F2 Guides / Collisions
F3 Shadow Compare
```

Remove the Boar debug state toggle.

Debug UI should optionally show:

```text
Player state
Player facing
Player frame
Sword equipped yes/no
Attack active yes/no
Boar state
Boar facing
```

Do not fill the normal screen with permanent technical text.

---

# 27. Source Mapping Data

Continue using the existing audited source mapping architecture:

```text
data/source_mapping/craftpix.json
systems/animation/source_sprite.gd
```

Extend it minimally for attack.

Do not replace it with a new generic manifest framework in this handoff.

Add attack metadata to the existing Craftpix mapping.

If different animation families need `loop=false`, support that in this same mapping structure.

---

# 28. `SourceSprite` Required Extension

The current `advance()` implementation wraps frames with modulo:

```gdscript
frame_index = (frame_index + 1) % frame_count
```

This only supports loops.

Extend it so mapping can declare:

```json
"loop": true
```

or:

```json
"loop": false
```

For non-loop state:

```text
last frame reached
→ do not modulo back to 0
→ mark finished once
→ notify owner/callback/signal
```

Suggested:

```gdscript
signal animation_finished(state: String)
```

Do not repeatedly emit `animation_finished` every process frame while sitting on the final frame.

Idle/Walk/Run behavior must remain unchanged.

---

# 29. Suggested Player State Handling

Do not over-engineer a large state machine.

A small model is sufficient:

```text
action_state = NONE / ATTACK
locomotion_state = IDLE / WALK / RUN
```

Pseudo-flow:

```text
if attacking:
    velocity = 0 or approved limited behavior
    keep attack pose
    wait for animation_finished
else:
    read movement
    set idle/walk/run
    if sword && attack_primary:
        start attack
```

If Walk Attack / Run Attack are implemented from source, movement policy may differ, but it must be explicitly documented.

---

# 30. Map Camera Review

Keep the current 640×360 viewport.

Improve the world composition around the existing camera.

The visual scene should make it possible to judge:

```text
character vs house
character vs road
character vs tree
character vs boar
```

without debug zoom.

Do not change camera zoom solely because the map is sparse.

Fix the map composition instead.

---

# 31. Asset-First Rule

For this entire handoff:

```text
source exists → use source
source unclear → inspect TMX
source missing → report
```

Never:

```text
source missing → approximate it manually
```

and never:

```text
map looks empty → fill with generated placeholder pixel art
```

The objective is to understand and use the Craftpix technical set correctly.

---

# 32. Tests

Update/add automated tests for the new behavior.

Minimum:

## 32.1 Sword attack geometry

Verify:

```text
Sword Attack source = correct PNG geometry
64×64 logical cell
8 frames/direction
4 source directions
```

## 32.2 Non-loop playback

Verify:

```text
Attack frame advances 0 → final
Attack does not wrap to 0
animation_finished emitted once
```

## 32.3 Root stability

Verify:

```text
player world position before attack
==
player world position after attack
```

when no movement is applied.

## 32.4 Equip rule

Verify:

```text
Tab-equivalent state:
unarmed idle/walk/run
↔
sword idle/walk/run
```

and attack only uses sword attack when Sword mode is enabled.

## 32.5 Boar behavior

Verify:

```text
Boar facing corresponds to movement direction
Boar does not rotate directions while stationary due to timer
Boar remains in configured roam area
```

## 32.6 Controls

Verify project input map contains:

```text
move_left
move_right
move_up
move_down
run
attack_primary
```

and `attack_primary` includes the chosen dev bindings.

---

# 33. Visual QA

Manual review must check:

### Map

```text
[ ] no longer reads as empty grass test board
[ ] house/road/tree scale feels coherent
[ ] walkable space remains readable
[ ] no obvious tile slicing errors
[ ] no texture blur
[ ] Y-sort looks correct
```

### Character

```text
[ ] 64×64 source frame retained
[ ] pivot/root does not jump
[ ] Idle/Walk/Run unchanged from DEV-R001
[ ] Sword layers remain aligned
[ ] Sword Attack maps to correct direction
[ ] attack does not restart uncontrollably
[ ] attack returns to valid locomotion
```

### Boar

```text
[ ] no fake timed facing rotation
[ ] idle while stationary
[ ] walk animation only while walking
[ ] facing matches actual movement
[ ] movement remains in test area
```

---

# 34. Required Screenshots / Capture

Produce at least:

1. improved full playtest area;
2. player near house/fence;
3. player behind/in front of tree for Y-sort review;
4. Sword Idle;
5. Sword Attack Down;
6. Sword Attack Left or Right;
7. Boar walking naturally in its roam area;
8. F2 debug view showing player/boar/environment footprints.

If possible also produce a short visual capture/video reference of Sword Attack and Boar movement, but static screenshots remain sufficient for acceptance.

---

# 35. Files Likely to Change

Expected:

```text
project.godot
data/source_mapping/craftpix.json
systems/animation/source_sprite.gd

scenes/player/player.gd
scenes/world/test_world.gd
scenes/world/test_world.tscn
scenes/fauna/boar_preview.gd
scenes/fauna/boar_preview.tscn
scenes/dev/debug_overlay.gd

art/vendor/craftpix/main_character/male/
  Sword_attack_*.png
  possibly Sword_Walk_Attack_*.png
  possibly Sword_Run_Attack_*.png

art/vendor/craftpix/main_character/home/
  only source files actually required by the improved map

tests/
docs/screenshots/
docs/reports/
WORKLOG.md
```

Actual paths may be adapted to match the existing clean structure.

Do not rename the entire project structure for this refinement.

---

# 36. Do Not Modify Source Vendor PNGs

Original Craftpix files under:

```text
art/vendor/craftpix/
```

must remain source-faithful.

Do not paint, resize, crop, shift, recolor, or overwrite them.

If a normalized derivative is ever needed, place it outside the original vendor source path and document why.

For DEV-R001.1, normalized derivative creation should generally not be necessary.

---

# 37. License / Repository Caution

DEV-R001 report records Craftpix license status as **Pending** for final distribution/publication.

Keep that caution.

Do not change license status to cleared merely because more vendor assets are imported.

Do not unnecessarily redistribute raw vendor files outside the private project workflow.

---

# 38. Acceptance Criteria

DEV-R001.1 is complete when:

```text
[PASS] DEV-R001 Idle/Walk/Run remains visually unchanged
[PASS] human character frame remains 64×64
[PASS] player pivot remains stable through attack
[PASS] map contains a coherent small Craftpix-based environment
[PASS] map includes more than grass + 2 trees + one road strip
[PASS] house/environment source is mapped without guessed slicing
[PASS] WASD legend reads Move / Direction
[PASS] attack_primary exists
[PASS] LMB and J trigger the same semantic attack action
[PASS] Sword Attack 8F works in four directions
[PASS] attack is one-shot and non-looping
[PASS] attack returns to valid locomotion
[PASS] attack spam does not restart the active attack
[PASS] B boar control is removed
[PASS] Boar no longer rotates through directions on a timer
[PASS] Boar Idle/Walk follows actual ambient movement
[PASS] Boar facing follows actual velocity
[PASS] F1/F2/F3 debug tools still function
[PASS] source assets remain nearest/pixel-safe
[PASS] tests pass
[PASS] screenshots produced
[PASS] WORKLOG updated
```

Walk Attack / Run Attack are optional for this handoff if their source import is clear and does not expand scope.

---

# 39. Required Codex Final Report

Codex must report:

1. commit SHA;
2. files changed;
3. new Craftpix files imported;
4. map/environment assets used;
5. exact Sword Attack mapping;
6. exact attack timing;
7. whether Walk Attack / Run Attack were implemented or deferred;
8. attack control bindings;
9. how non-loop playback was implemented;
10. confirmation that pivot/root did not change;
11. Boar ambient movement logic;
12. Boar roam bounds;
13. removed `B` behavior confirmation;
14. screenshots/captures;
15. automated test results;
16. any missing/ambiguous Craftpix references;
17. recommended next step.

Do not automatically proceed to combat, inventory, or NPC systems after completion.

---

# 40. Final Instruction to Codex

Refine the **playtest quality**, not the game's feature count.

Preserve the working DEV-R001 character foundation.

Use the real Craftpix environment and Sword Attack source.

Replace fake inspection behavior with believable lightweight presentation:

```text
empty technical board
→ small coherent RPG test environment

stationary rotating boar preview
→ simple ambient wandering boar

sword locomotion only
→ sword locomotion + real source attack
```

Most importantly:

> Do not break the 64×64 character mapping, `(32,44)` working root/pivot, stable feet alignment, or source-faithful frame placement while adding the new visual states.
