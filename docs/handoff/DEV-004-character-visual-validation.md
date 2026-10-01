# DEV-004 — Character Visual Validation / Codex Handoff

**AEVORA • Godot 4 • VIS-001 Validation**

Status: Implementation-validation handoff.  
Scope: validate the agreed VIS-001 character visual contract in Godot before expanding into additional character/gameplay systems.

---

## 1. Purpose

DEV-004 is a **visual architecture validation pass**, not a gameplay expansion pass.

The goal is to prove that the current VIS-001 rules work correctly in Godot 4 and remain flexible enough for future character generation, equipment layering, animation variants, NPC reuse, and AI-assisted sprite production.

This handoff must validate:

1. 32×32-class character readability inside a minimum 64×64 authoring/frame canvas;
2. four-direction character presentation;
3. state-specific animation frame counts and timing;
4. stable character center and stable world/ground anchor;
5. modular character visual layers;
6. direction-aware equipment occlusion;
7. manifest-driven animation playback;
8. nearest-neighbor / pixel-safe rendering;
9. transparent-alpha and sprite-sheet validation;
10. a repeatable workflow for future AI-generated character animation.

Do **not** add unrelated gameplay systems until this validation pass is complete.

---

## 2. Required Reading Before Editing

Codex must inspect the current repository and read:

- `docs/handoff/DEV-001-godot-project-foundation.md`
- `docs/handoff/DEV-002-first-visual-slice.md`
- `docs/handoff/DEV-003-prototype-stabilization-interaction-contract.md`
- current `WORKLOG.md`
- current Player scene/script
- current project input map and rendering/import settings
- current tests under `tests/`

Design/source-of-truth references:

- ART-001 — AEVORA Visual Direction / Pixel Art Specification
- ART-002 — AEVORA Asset Registry
- ARTGEN-001 — `Character Walk 6F Contract (Draft)`

ARTGEN-001 Google Doc:

`https://docs.google.com/document/d/1bb0M7VARkl6P3NWGtRt5D0zYKOu7upzAUjJauyDal88/edit`

**Critical:** ARTGEN-001 is a **reference prompt**, not a frozen production specification. It contains several useful invariants that must be preserved, but it also contains older numeric assumptions that have been superseded by VIS-001.

Do not copy ARTGEN-001 blindly into an image generator.

---

# 3. Current VIS-001 Contract

## 3.1 Character visual scale

Current agreed baseline:

```text
visual readability class : 32×32-class high-detail pixel character
minimum authoring canvas : 64×64 per frame
runtime display          : may be 32-class or 64-class after QA
large monsters/characters: may use larger canvases
```

Important:

```text
sprite canvas
!= visual character footprint
!= world footprint
!= collision footprint
```

A 64×64 frame does **not** mean the body should fill 64×64.

The exact final occupied body bounding box is still reviewable through Godot testing.

Do not reintroduce the old assumption that a standard human must visually occupy 48–52 px of the 64 px frame.

---

## 3.2 Four directions

Every minimum Core character state must support:

```text
down
up
left
right
```

Preferred new atlas row order:

```text
row 1 = down
row 2 = up
row 3 = left
row 4 = right
```

However imported/generated sheets may use another order if the manifest maps the rows explicitly.

No runtime code may assume row order from image layout without metadata.

---

## 3.3 Minimum Core animation states

Required minimum states:

```text
idle
walk
run
attack
hurt
dead
tool
```

All seven states require all four directions.

Attack and Tool are **state families**, not one universal motion.

Examples:

```text
attack_unarmed_punch_01
attack_sword_slash_01
attack_spear_thrust_01

tool_hoe
tool_axe
tool_pickaxe
tool_watering
```

---

## 3.4 State-specific frame count

There is **no universal six-frame rule**.

Current production starting points:

```text
idle   = 4 frames baseline
walk   = 6 frames baseline
run    = 8 frames baseline
attack = 6 frames baseline for a simple attack
hurt   = 3 frames baseline
dead   = 6 frames baseline
tool   = 6 frames baseline
```

These are starting points, not caps.

Actual frame count is data-driven per state / animation variant.

Examples:

```text
idle: 2–4 may be valid
walk: 4–8 may be valid
run: 6–8 may be valid
attack: 3–6+ depending on attack
hurt: 2–3 may be valid
dead: 4–6 may be valid
tool: action-specific
```

No controller may hard-code `6`.

---

## 3.5 State-specific timing

There is also **no universal 100 ms-per-frame rule**.

Current timing direction:

```text
idle   : approximately 300–500 ms/frame
walk   : approximately 100–150 ms/frame
run    : approximately 60–100 ms/frame
attack : phase-based / variable
hurt   : action-specific
dead   : action-specific
tool   : action-specific
```

Exact animation timing is stored explicitly.

Example:

```json
{
  "frame_count": 6,
  "durations_ms": [120, 100, 100, 120, 100, 100],
  "loop": true
}
```

Attack may deliberately use uneven timing:

```text
anticipation
→ launch
→ impact
→ follow-through
→ recovery
```

The impact frame may be held longer than a transition frame.

Godot rendering/physics FPS must remain independent from authored sprite timing.

---

# 4. The Most Important Alignment Rule

This section is non-negotiable.

The main risk during sprite generation, cleanup, atlas extraction, automatic trimming, or animation correction is accidentally causing the character to move inside the frame.

The user has explicitly approved the current **stable-center / stable-footing behavior** and does not want future improvements to destroy it.

There are two separate alignment concepts.

## 4.1 Body Alignment Point

The body alignment reference is approximately the pelvis / hip center.

For a 64×64 frame:

```text
horizontal body center = X 32
```

The exact visible body width may change by costume/body type, but the body must not wander left/right between frames.

For ordinary in-place locomotion:

```text
pelvis X(frame 1)
= pelvis X(frame 2)
= ...
= pelvis X(last frame)
```

Small limb movement is expected.

Root/body drift is not.

---

## 4.2 World / Ground Anchor

The world anchor represents the character node's stable location in the game world.

Conceptually:

```text
world anchor = stable bottom-center ground/root point
```

The historical ARTGEN-001 prompt uses:

```text
X = 32
Y = 56
```

That Y value is **not final anymore**.

Current VIS-001 testing has discussed a provisional value nearer:

```text
X = 32
Y ≈ 48
```

but the exact Y must be validated against the approved visual scale in Godot.

Therefore:

> Preserve the existence and stability of the anchor, but do not blindly preserve the old Y=56 number.

The manifest must contain the chosen anchor explicitly.

Example:

```json
"anchor": {
  "x": 32,
  "y": 48
}
```

The test may tune `y`, but once an animation set is aligned to its declared anchor, **do not allow that anchor to move between frames**.

---

## 4.3 Do not auto-center using opaque bounding boxes

This is a major implementation warning.

Do **not** align each frame by:

```text
opaque_bbox.center
opaque_bbox.bottom
```

because moving arms, legs, hair, weapons, or scarves change the opaque bounds.

If each frame is recentered from its own bounding box, the torso will visibly jitter even if the source motion was correct.

Bad process:

```text
frame 1 → trim opaque bounds → center result
frame 2 → trim opaque bounds → center result
frame 3 → trim opaque bounds → center result
```

This creates artificial body drift.

Preferred process:

```text
fixed 64×64 frame
+
explicit pelvis/body center
+
explicit world/ground anchor
+
integer-pixel correction only when required
```

If a cleanup script needs to translate a frame, alignment must be based on the explicit body/root landmarks, not on the changing outer silhouette.

---

## 4.4 Do not independently crop animation frames

Do not destructively auto-trim every animation frame to its smallest rectangle.

Preferred:

```text
all locomotion frames remain on the agreed frame canvas
```

If an export pipeline needs trimmed textures later, it must preserve per-frame pivot/anchor offsets exactly in metadata.

For DEV-004, keeping the source/runtime validation frames on stable fixed canvases is preferred because it makes anchor errors visible.

---

# 5. ARTGEN-001 — What Is Already Good and Must Be Preserved

ARTGEN-001 contains several strong ideas that produced visibly better consistency.

These are **reference invariants**.

They should survive future prompt evolution unless a later approved design explicitly replaces them.

## 5.1 Fixed camera / fixed perspective

Keep:

- 3/4 top-down RPG view;
- locked camera;
- same apparent scale between frames;
- no zoom;
- no camera rotation;
- no arbitrary perspective shift.

The treadmill mental model is useful:

> The character walks in place while the camera and world root remain fixed.

Do not "improve" the sprite by making each frame a slightly different camera angle.

---

## 5.2 Same character identity across frames

Keep:

- same face;
- same hairstyle;
- same body proportions;
- same clothing design;
- same pixel density;
- same visual scale;
- same palette logic.

A generation that produces individually attractive frames but changes facial structure, hair shape, shoulder width, leg length, or body scale between frames is a failed animation set.

---

## 5.3 Stable center

ARTGEN-001 strongly emphasizes:

```text
X = center
torso/pelvis does not drift horizontally
```

This is good.

Do not weaken this requirement.

When correcting leg movement, arm movement, clothing, shading, or detail, do not move the entire body.

---

## 5.4 Stable planted-foot / ground relationship

The prompt's invisible ground-baseline concept is also good.

During locomotion:

- the planted/support foot should visually contact the same ground plane;
- the swing foot may lift;
- the whole sprite must not appear to bounce because the export was recentered differently;
- feet must not randomly float or sink.

The exact anchor Y may be changed during the validation pass, but the **ground relationship must remain internally stable**.

---

## 5.5 Continuous gait

Keep the walk-cycle concept:

```text
Contact A
→ Down A
→ Passing A
→ Contact B
→ Down B
→ Passing B
→ back to Contact A
```

The key strength is not merely "six poses".

The strength is that each leg follows a continuous temporal path.

Do not replace this with six unrelated attractive walking poses.

---

## 5.6 Near-leg / far-leg side-view reasoning

This was introduced because generic left-leg/right-leg wording produced side-view errors.

Keep the visual reasoning:

```text
NEAR LEG
FAR LEG
```

for left/right profile animation generation and QA.

This makes knee direction and foot trajectory easier to inspect.

---

## 5.7 Correct foot trajectory

Keep:

```text
rear contact
→ heel lift
→ knee flex
→ swing foot leaves ground
→ passes below/near hip
→ moves forward
→ front contact
```

Reject:

- teleporting feet;
- knee direction reversal;
- leg-length changes;
- duplicated feet/legs;
- both feet glued to the baseline in every frame.

---

## 5.8 Small locomotion body bob

For normal walk, the 1–2 px vertical bob concept is useful.

Do not introduce large whole-body bouncing merely to make the animation appear more dramatic.

However, this exact 1–2 px amount does **not** automatically apply to Run, Hurt, Dead, Attack, or Tool.

---

## 5.9 Opposed arm-leg rhythm

For ordinary walking/running, keep natural opposite arm/leg motion unless the held equipment/action specifically changes it.

---

## 5.10 Seamless loop check

Keep explicit QA for:

```text
last frame → first frame
```

An animation is not complete just because frames 1→N look plausible.

Loop closure must be checked.

---

## 5.11 Base character without asymmetric equipment

For generating or validating the reusable base body, omitting:

- side satchel;
- sword;
- shield;
- side pouch;
- asymmetric armor;
- weapon holster;

is still a good rule.

Those elements belong to modular visual layers.

---

## 5.12 Hard pixel-art discipline

Keep:

- hard pixel edges;
- no accidental anti-aliasing;
- no blur;
- no soft painted edges;
- deliberate pixel clusters;
- consistent pixel scale.

Also validate the actual output. Do not trust the generation prompt alone.

---

# 6. ARTGEN-001 — Known Weaknesses / Superseded Parts

Codex must understand these before using the prompt.

## 6.1 Old 48–52 px visible character height

ARTGEN-001 says:

```text
Target visual character height: approximately 48–52 pixels
```

This has been superseded.

Current direction:

```text
32×32-class visual readability
inside a minimum 64×64 authoring/frame canvas
```

Do not enlarge the body to 48–52 px just because the old prompt says so.

The exact occupied body pixels remain a validation result.

---

## 6.2 Old Y=56 ground anchor

ARTGEN-001 repeatedly uses:

```text
ground baseline Y = 56
```

Treat this as historical reference only.

DEV-004 must test the current character scale and choose/record a suitable anchor.

The important invariant is:

```text
same anchor across frames/layers
```

not the old number `56`.

---

## 6.3 Old row order

ARTGEN-001 uses:

```text
Up
Down
Left
Right
```

Current preferred new atlas order is:

```text
Down
Up
Left
Right
```

Do not silently reinterpret an existing generated sheet.

Every generated/imported atlas must declare its direction mapping in the manifest.

---

## 6.4 Fixed 6×4 sheet applies only to the walk reference

ARTGEN-001 is specifically a six-frame walk prompt.

Do not extend this rule to:

- Idle;
- Run;
- Hurt;
- Dead;
- Attack;
- Tool.

Each state has its own frame count.

A state may also be generated as separate rows/files and composed later.

---

## 6.5 Fixed 384×256 sheet is not a global character rule

`384×256` comes from:

```text
6 columns × 64 px
4 rows × 64 px
```

It is therefore only a valid layout for a 6-frame, 4-direction, 64×64-per-frame atlas.

Example:

```text
Run = 8 frames
→ 512×256 if exported as one 8×4 atlas
```

Do not force Run into 384×256.

---

## 6.6 Old 20–28 color limit

ARTGEN-001 uses an approximate 20–28 color constraint.

Current VIS-001 does **not** impose one rigid global palette count.

Use compact local material ramps, but do not degrade a layered character just to satisfy an arbitrary total color number.

---

## 6.7 Exact left/right mirroring is for symmetric base art only

For a symmetric naked/base character, left/right mirroring is useful.

Do not blindly mirror asymmetric:

- armor;
- sheath;
- shield;
- quiver;
- pouch;
- hair accessory;
- shoulder equipment;
- weapon placement.

Those assets require direction-aware rendering.

---

## 6.8 "No torso tilt" is locomotion guidance, not a universal state law

For a basic walk, excessive torso tilt is undesirable.

But future:

- Run;
- Attack;
- Hurt;
- Dead;
- Tool

may require intentional body lean or rotation.

The invariant is the **root/world anchor**, not an unnaturally frozen torso.

---

## 6.9 "Same body height in every frame" means same scale, not identical pose bounds

A Dead animation may become horizontally long.

A Hurt animation may compress.

A Tool animation may raise both arms.

Do not scale the character down to force all poses into the same opaque bounding box.

Keep world scale consistent and enlarge the animation canvas when necessary.

---

## 6.10 Transparent background must be verified programmatically

Previous AI image-generation tests requested transparent PNG but visually produced a non-transparent/brown background.

Therefore:

> Prompt text saying "transparent" is not evidence that the file has a valid alpha channel.

The validator must inspect the actual image.

---

# 7. Prompt Evolution Protocol for Codex

If Codex is instructed to generate a new character or animation, use the following process.

Do not simply paste ARTGEN-001 unchanged.

## Step 1 — Identify the requested asset

Determine:

```text
character visual ID
base body / hair / outfit / armor / equipment
animation state
animation variant
directions required
frame count
frame timing
canvas size
```

Example:

```text
visual_id     = body_human_base_001
state         = walk
directions    = down, up, left, right
frame_count   = 6
canvas        = 64×64
```

---

## Step 2 — Separate invariants from tunable parameters

### Preserve unless explicitly changed

```text
same character identity
fixed 3/4 camera
consistent pixel density
stable X/body center
stable world/root anchor
consistent scale
hard pixel-art edges
four directions
continuous anatomical motion
no cross-cell overlap
no unintended baked shadow
true alpha required
```

### Adapt according to state/asset

```text
frame count
frame duration
pose amplitude
canvas size
body bob
torso lean
weapon/tool motion
palette size
direction row order
animation-specific secondary motion
```

---

## Step 3 — Start from one canonical visual identity

Before generating many states, establish one approved character identity.

Preferred order:

```text
canonical idle/base character
→ walk
→ run
→ hurt
→ dead
→ unarmed/simple attack
→ tool
→ equipment layers
```

Use the approved base character/reference image when the generation tool supports image conditioning/reference.

Do not ask the generator to independently reinvent the same character seven times.

---

## Step 4 — Generate base body before equipment

For initial validation:

```text
no sword
no shield
no satchel
no cape
no one-sided armor
```

Validate body movement first.

Equipment is generated later against the same animation/anchor contract.

This makes it possible to distinguish:

```text
body animation bug
vs
equipment alignment bug
```

---

## Step 5 — Generate one animation family deliberately

It is acceptable to generate:

- one full state atlas;
- one direction at a time;
- smaller frame groups;

if that improves consistency.

However the final normalized runtime result must satisfy the manifest.

Do not assume that forcing the model to generate every state in one enormous sheet is more correct.

Consistency and validation are more important than one-shot generation.

---

## Step 6 — Preserve center/root during correction

If one frame has a bad leg:

> Correct the leg, not the entire body position.

If one hand is wrong:

> Correct the hand/arm, not the sprite center.

If shading is wrong:

> Correct shading, not scale/anchor.

If a frame requires a full regeneration and the regenerated torso moves:

> reject or realign it before acceptance.

Do not accept a visually prettier correction if it causes center or ground-anchor drift.

---

## Step 7 — Normalize without bounding-box recentering

Post-processing may:

- verify dimensions;
- split atlas cells;
- ensure RGBA;
- remove an unwanted flat background where safely possible;
- translate a frame by integer pixels when explicit body/root landmarks prove it is misaligned;
- compose the normalized atlas;
- write manifest metadata.

Post-processing must not:

- independently scale frames;
- stretch anatomy;
- auto-center from opaque bounds;
- independently crop frames and discard pivot information;
- smooth/anti-alias;
- introduce fractional-pixel positioning.

---

## Step 8 — Validate before calling the asset approved

AI output is always:

```text
candidate
```

until validation passes.

Do not call an image "production-ready" because the generation prompt asked for production-ready output.

---

# 8. Runtime Naming / File Contract

Runtime tokens:

```text
lowercase_snake_case
```

Registry IDs remain:

```text
CHAR-001
FAUNA-001
...
```

Canonical states:

```text
idle
walk
run
attack
hurt
dead
tool
```

Canonical directions:

```text
down
up
left
right
```

Recommended runtime filename pattern:

```text
<visual_id>_<layer>_<state>[_<variant>].png
```

Examples:

```text
body_human_base_001_body_walk.png
body_human_base_001_body_run.png
hair_short_001_hair_walk.png
weapon_sword_iron_001_main_hand_attack_slash_01.png
```

For single-direction files only:

```text
..._<direction>.png
```

Do not encode source-history strings such as:

```text
final_v7_fixed_final2
```

into canonical runtime filenames.

Source/history belongs in ART-002 / Git history.

---

# 9. Proposed Runtime Folder Structure

Codex must inspect the current repo before creating directories, but the preferred organization is:

```text
res://art/characters/
  body/
  hair/
  outfit/
  appearance/
  manifests/

res://art/equipment/
  weapons/
  armor/
  head/
  back/
  accessories/
  tools/

res://art/shared/
  shadows/
  vfx/
```

If the current repository already has a better compatible convention, extend it rather than duplicating parallel structures.

The key rule is:

> Reusable body/hair/equipment visuals must not be copied into every player/NPC instance folder.

---

# 10. Manifest Contract

JSON is the authoritative interchange/source manifest.

Godot may generate/load `.tres` resources from it, but runtime metadata must not be implicit in filenames.

Minimum example:

```json
{
  "schema_version": 1,
  "visual_id": "body_human_base_001",
  "canvas": {
    "width": 64,
    "height": 64
  },
  "anchor": {
    "x": 32,
    "y": 48
  },
  "directions": ["down", "up", "left", "right"],
  "animations": {
    "walk": {
      "file": "body_human_base_001_body_walk.png",
      "frame_count": 6,
      "loop": true,
      "durations_ms": [120, 100, 100, 120, 100, 100],
      "direction_rows": {
        "down": 0,
        "up": 1,
        "left": 2,
        "right": 3
      }
    }
  }
}
```

`anchor.y = 48` above is a test example, not a command to freeze that value before validation.

The manifest must support:

```text
frame_count
durations_ms
loop
file/atlas
direction mapping
canvas size
anchor/pivot
visual layer/channel
back/front part behavior where required
visible_on_character
```

No controller may assume:

```text
6 frames
100 ms/frame
fixed row order
one universal atlas shape
```

---

# 11. Character Visual Composition

Minimum visual composition architecture:

```text
CharacterVisual
├── Shadow
├── BackLayers
│   ├── HairBack
│   ├── BackEquipment
│   └── EquipmentBackParts
├── BodyLayers
│   ├── Body
│   ├── Hair/BaseHead as required
│   ├── Outfit
│   ├── Armor
│   └── Feet/Hands as required by asset strategy
├── FrontLayers
│   ├── Headgear
│   ├── Accessories
│   ├── MainHand
│   ├── OffHand
│   └── EquipmentFrontParts
└── VFX
```

Implementation does not need to instantiate every possible slot during DEV-004.

A minimum proof is:

```text
Shadow
Body
Hair
Outfit
BackEquipment/Weapon test layer
FrontEquipment/Weapon test layer
VFX placeholder
```

All ordinary visual layers must share:

```text
state
direction
frame index
frame duration
anchor
visual scale
```

---

# 12. Direction-Aware Layering Test

DEV-004 must prove that one test equipment visual can change occlusion by direction.

For example:

```text
DOWN:
body
→ shield/front weapon

UP:
shield/back weapon
→ body
```

The exact test item can be a placeholder.

This test is architectural.

It does not need production-quality equipment art.

Do not permanently bake the test weapon/shield into the body sprite.

---

# 13. Godot Validation Scene

Create a dedicated character visual validation scene.

Suggested path:

```text
scenes/dev/character_visual_validation.tscn
```

If the project already has a better development/test-scene convention, use that convention and document the actual path.

Suggested hierarchy:

```text
CharacterVisualValidation
├── BackgroundTest
├── CharacterRoot
│   └── CharacterVisual
│       ├── Shadow
│       ├── BackLayers
│       ├── BodyLayers
│       ├── FrontLayers
│       └── VFX
├── Camera2D
└── CanvasLayer
    └── DebugUI
```

Debug UI should display at least:

```text
visual_id
state
direction
frame index / frame count
current frame duration
loop yes/no
anchor x/y
runtime display scale
active visual layers
```

---

# 14. Test Controls

Provide simple deterministic test controls.

Suggested:

```text
1 = idle
2 = walk
3 = run
4 = attack
5 = hurt
6 = dead
7 = tool
```

Direction:

```text
Arrow keys / WASD
```

Equipment/layer test:

```text
Q / E = previous / next test equipment or appearance setup
```

Optional debug toggles:

```text
F1 = show/hide anchor crosshair
F2 = show/hide frame/canvas bounds
F3 = switch representative test background
F4 = slow-motion playback
```

Do not override existing production input actions destructively if avoidable.

Development-only input mappings are acceptable if clearly isolated.

---

# 15. Anchor Debug Visualization

DEV-004 must make anchor problems visible.

Add optional debug overlays for:

```text
frame canvas rectangle
vertical center line X=32
body alignment reference
world/ground anchor cross
ground baseline
```

The overlay must not modify animation data.

When switching frames, the user should be able to visually confirm:

```text
center line does not wander
world anchor does not wander
planted foot relationship remains stable
```

For Dead, the body may collapse away from the feet visually, but the `CharacterRoot` world position must remain fixed.

---

# 16. Character Generation Test Asset

DEV-004 does not require a final canonical Player Character.

Use either:

1. a temporary cleaned version of the approved visual-reference character;
2. a newly generated temporary base character following the Prompt Evolution Protocol;
3. a purpose-built validation dummy that still follows VIS-001.

If Codex generates a new temporary character, it must be explicitly marked:

```text
prototype / validation
```

Do not silently promote it to final/remaster/canonical status.

The approved visual test established the **quality/reference direction**, not automatic approval of every generated PNG.

---

# 17. Rendering Rules

For core pixel character/equipment art:

```text
nearest-neighbor filtering
hard alpha edges
no accidental interpolation blur
integer/pixel-conscious positioning
no fractional scale drift between layers
```

Runtime `64 → 32` may be tested.

If 32-class runtime presentation loses too much important detail, document that result rather than artificially enlarging the body inside the source frame.

Do not change character proportions only to compensate for bad scaling configuration.

---

# 18. Palette / Shading Rules

Preserve current VIS-001 agreement:

- selective approximately 1 px dark/color-shifted outline where useful;
- no universal pure-black boxing;
- clustered pixel shading;
- material-aware shadow/base/highlight ramps;
- compact local palette;
- no rigid global total-color cap;
- consistent authored light logic, approximately neutral top / upper-left screen-space;
- skin, cloth, leather, wood, metal should remain materially distinguishable;
- hard alpha on normal character/equipment edges;
- semi-transparency reserved for Shadow/VFX/special materials.

DEV-004 does not need to build a dynamic lighting system.

It only needs to ensure the source sprite contract remains compatible with later world tint/modulation.

---

# 19. Alpha Validation

A production-ready validator must inspect actual PNG data.

Required checks:

```text
[PASS] image is PNG
[PASS] image has alpha channel
[PASS] expected transparent background pixels are alpha 0
[PASS] no accidental opaque full-frame background
[PASS] no unwanted semi-transparent anti-aliased fringe on core sprite edges
```

Do not rely on filename, generator response, or prompt text.

---

# 20. Atlas / Frame Validation

Validator should verify at minimum:

```text
image dimensions match manifest layout
frame size matches declared canvas
frame count matches metadata
direction mapping is complete
durations_ms count matches frame_count
all Core directions exist
frames do not overlap adjacent cells
no opaque pixel leaks into neighboring atlas cells
anchor lies within expected frame coordinate space
```

For an asset declared complete for a Core state:

```text
down/up/left/right
```

must all be present.

Incomplete prototype/source assets may exist in ART-002, but they must not be mislabeled production-ready.

---

# 21. Center / Ground Stability Validation

Automated image analysis can assist, but it must not replace visual QA.

At minimum produce a diagnostic that can identify suspicious drift.

Possible metrics:

```text
declared anchor identical across every frame
canvas dimensions identical
frame origin identical
body-center guide visually reviewable
foot/ground contact review sheet generated
```

Optional:

- create a contact sheet with the center line and ground baseline drawn as debug overlays;
- calculate coarse body-mask centroid only as a warning metric.

Do **not** automatically correct frames from centroid/bounding-box calculations.

Those metrics change with limb pose.

---

# 22. Manual QA Checklist

Every candidate animation must be reviewed at:

```text
native 64×64 frame view
intended in-game presentation scale
light terrain
dark terrain
```

For locomotion:

```text
[ ] same character identity
[ ] same visual scale
[ ] camera/perspective stable
[ ] pelvis/body center does not drift left/right
[ ] root/world anchor does not change frame-to-frame
[ ] support foot contacts coherent ground plane
[ ] swing foot actually leaves ground
[ ] no leg teleport
[ ] knees bend naturally
[ ] arms follow intended motion
[ ] last frame returns naturally to first
[ ] no neighbor-frame overlap
[ ] no background contamination
```

For layers:

```text
[ ] body and equipment use same frame/state/direction
[ ] equipment does not lag one frame behind
[ ] back/front placement changes correctly by direction
[ ] no layer scale mismatch
[ ] no layer anchor mismatch
```

---

# 23. Specific Regression Rule — Do Not Break What Already Works

When improving an existing generated animation, the following regression is explicitly unacceptable:

```text
before:
center stable
feet stable
animation slightly imperfect

after:
legs look prettier
BUT
body shifts horizontally
OR
ground contact jumps
OR
character scale changes
```

In that case the "improved" result must be rejected.

Priority order for correction:

```text
1. character identity
2. world/root anchor stability
3. body center stability
4. scale/perspective consistency
5. anatomical motion continuity
6. layer synchronization
7. shading/detail polish
```

Polish does not outrank spatial stability.

---

# 24. Development Scope

DEV-004 may implement:

- visual manifest loader;
- animation metadata parser;
- character visual composition component;
- debug validation scene;
- temporary validation art;
- sprite/manifest validator;
- test scripts;
- debug overlays;
- state/direction switching;
- data-driven frame timing.

DEV-004 must **not** implement:

- final combat damage;
- full inventory;
- crafting;
- physiology/metabolism;
- NPC simulation;
- dialogue expansion;
- final equipment database;
- final character creator;
- final aging visuals;
- skill/progression systems;
- world-map expansion.

Attack/Tool are visual test states only in this pass.

---

# 25. Suggested Implementation Sequence

Execute in this order.

### Phase A — Repository audit

1. inspect current Player and animation code;
2. inspect existing pixel import settings;
3. inspect any existing reusable animation/state logic;
4. avoid duplicating systems that already satisfy the contract.

### Phase B — Manifest

1. define JSON schema/version 1;
2. create one validation character manifest;
3. include canvas, anchor, directions, states, frame count, durations, loop, file mapping;
4. validate malformed metadata.

### Phase C — CharacterVisual component

1. build reusable layered visual node/component;
2. ensure all ordinary layers share one playback state/frame;
3. implement direction-aware front/back layer selection;
4. keep movement physics outside this component.

### Phase D — Validation scene

1. build standalone validation scene;
2. add debug UI;
3. add anchor/canvas overlays;
4. add background contrast tests;
5. add manual state/direction controls.

### Phase E — Asset validation

1. load/generate temporary test character;
2. verify RGBA/alpha;
3. verify atlas dimensions;
4. verify anchors;
5. verify state-specific frame counts;
6. verify variable frame timing.

### Phase F — Regression tests

1. script metadata validation;
2. script scene-load smoke test;
3. verify bad manifest is rejected;
4. verify no hard-coded six-frame assumption;
5. verify no hard-coded direction-row assumption.

### Phase G — Report

Document:

```text
what passed
what failed
actual test asset dimensions
chosen provisional anchor
runtime scale findings
any VIS-001 rule that should be revised
```

Do not silently alter the design contract when a test reveals a problem.

Report the finding first.

---

# 26. Suggested Files

Codex must adapt paths to the actual repo after inspection.

Possible additions:

```text
docs/handoff/
  DEV-004-character-visual-validation.md

scenes/dev/
  character_visual_validation.tscn

systems/character_visual/
  character_visual.gd
  character_visual_manifest.gd
  character_animation_player.gd

data/character_visual/
  body_human_base_001.json

tests/
  dev_004_character_visual_test.gd
  dev_004_manifest_validation_test.gd

art/prototype/dev_004/
  characters/
  equipment/
```

Do not create duplicate directories if equivalent project structures already exist.

---

# 27. Acceptance Tests

DEV-004 is complete only when all of the following are demonstrated.

## Architecture

```text
[PASS] visual playback is manifest-driven
[PASS] no universal six-frame hard-code
[PASS] no universal 100 ms timing hard-code
[PASS] direction row mapping comes from metadata
[PASS] movement physics is independent from animation playback
```

## Character

```text
[PASS] idle supports four directions
[PASS] walk supports four directions
[PASS] run supports four directions
[PASS] attack supports four directions
[PASS] hurt supports four directions
[PASS] dead supports four directions
[PASS] tool supports four directions
```

Temporary art may be rough, but the architecture must support all states.

## Anchor

```text
[PASS] world/root anchor does not shift between frames
[PASS] body center does not jitter because of auto-cropping/recentering
[PASS] changing animation state does not teleport CharacterRoot
[PASS] changing equipment does not shift CharacterRoot
[PASS] frame/canvas changes preserve declared pivot/anchor
```

## Layers

```text
[PASS] Body/Hair/Outfit test layers are synchronized
[PASS] test equipment can render behind/in front according to facing
[PASS] no one-frame layer lag
[PASS] visible_on_character=false can suppress a visual without unequipping gameplay data
```

## Rendering

```text
[PASS] nearest-neighbor character rendering
[PASS] no obvious interpolation blur
[PASS] transparency is real alpha
[PASS] visual remains readable over representative light/dark terrain
```

## Validation

```text
[PASS] invalid frame count fails validation
[PASS] duration-count mismatch fails validation
[PASS] missing direction fails production validation
[PASS] invalid atlas dimensions fail validation
[PASS] opaque accidental background is detected or clearly reported
```

---

# 28. Required Output From Codex

At completion, Codex must provide:

1. list of files added/modified;
2. test commands used;
3. validation-scene launch instructions;
4. screenshot(s) or capture reference if available;
5. test results;
6. chosen/provisional anchor result and reasoning;
7. any visual regressions found;
8. any recommended VIS-001 spec change;
9. update to `WORKLOG.md`.

Do not mark a Review value as permanently locked without user approval.

---

# 29. Stop Conditions

Stop and report instead of guessing if:

- approved/reference character source cannot be located;
- source image dimensions/layout are ambiguous;
- alpha cannot be reliably recovered;
- generated character identity changes materially across states;
- alignment correction would require destructive scaling;
- a prompt change fixes anatomy but repeatedly destroys stable center/ground anchor;
- existing runtime architecture conflicts materially with this handoff;
- Godot import behavior makes the expected pixel-safe result impossible without a design change.

When blocked:

```text
preserve current working behavior
document the evidence
propose the smallest correction
wait for review if it changes VIS-001
```

---

# 30. Final Codex Instruction

Implement DEV-004 as a **validation harness for VIS-001**.

Treat ARTGEN-001 as an evolving generation reference.

Preserve its proven strengths:

```text
stable center
stable ground/root relationship
fixed camera
consistent identity
continuous gait
hard pixel-art discipline
```

Do not preserve its superseded numeric assumptions merely because they appear in the old prompt.

When improving generated art:

> Never trade anchor stability, body-center stability, consistent scale, or ground contact for prettier individual frames.

The purpose of this pass is to make AEVORA's character pipeline **repeatable, inspectable, data-driven, and safe to evolve** before further character systems are built.
