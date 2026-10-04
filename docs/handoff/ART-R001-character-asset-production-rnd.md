# ART-R001 — Character Asset Production R&D Setup & Tool Evaluation

**AEVORA • Art / Character Pipeline R&D • Godot 4**

Status: **Implementation handoff — R&D / tooling / comparison**  
Current AEVORA repository HEAD reviewed before handoff: `dfea8e25706cdfdb23e09e00f7532a1f39b68ed4`  
Validated runtime foundation: DEV-R001 → DEV-R001.3

---

## 1. Purpose

ART-R001 starts a new workstream. This is **not** DEV-R001.4 and is **not** a gameplay feature handoff.

Goal:

> Establish a repeatable production experiment for an original AEVORA human character and evaluate which tooling/workflow is practical before committing to a final commercial art pipeline.

Candidate tools:

- Aseprite
- Top Down Sprite Maker
- Sprite Studio / `JohnKinyanjui/sprite-maker`

The first R&D pass must answer:

```text
Can we create an original 64×64 AEVORA character
with stable identity, stable root, four directions,
and usable Idle + Walk animation,
then validate it inside the existing Godot baseline?
```

---

## 2. Preserve the validated runtime baseline

Do not disturb the current DEV-R001.3 playable slice.

Preserve:

```text
Godot 4 Compatibility
Logical viewport = 640×360
Reference display = 1280×720
Integer display scale = 2×

Human technical frame = 64×64
Current Craftpix comparison pivot = (32,44) provisional
Player feet = 10×6
Walk = 48 px/s
Run = 112 px/s

Directions:
down
left
right
up
```

Do not replace the current Player asset in the normal main scene during ART-R001.

ART-R001 must use a **dedicated dev comparison scene**.

---

## 3. Documentation workflow

Keep the existing project documentation model.

Do not create `CONTEXT.md`.

Use:

```text
HANDOFF
= what should be done

WORKLOG.md
= concise chronological summary

docs/reports/
= detailed implementation evidence, problems, tests and lessons
```

Create:

```text
docs/reports/art-r001-character-asset-production-rnd.md
```

Add only a concise ART-R001 summary to `WORKLOG.md`.

---

## 4. R&D principle

ART-R001 evaluates the **pipeline**, not final protagonist quality.

Do not attempt:

```text
full final protagonist
Run
all weapons
armor system
tool animations
hurt/death
combat animation library
NPC generator
complete modular wardrobe
```

First candidate:

```text
AEVORA Base Human v0
64×64
4 directions
Idle
Walk
```

If this contract is not reliable, adding more states only multiplies cleanup work.

---

## 5. Craftpix role

Craftpix remains a **technical runtime benchmark**.

It may be displayed beside the R&D candidate to compare:

```text
gameplay scale
readability
root stability
camera relationship
animation cadence
silhouette size
```

Do **not** use Craftpix PNGs as image-generation or style references.

Do not prompt “make this look like Craftpix”.

Allowed:

```text
Craftpix displayed in Godot comparison scene
Craftpix measurements used as technical benchmark
```

The original AEVORA candidate must originate from an AEVORA text/design brief.

---

## 6. External tool isolation

Do not clone/install large third-party applications inside the AEVORA Git repo.

Suggested Windows layout:

```text
D:\Project\Game RPG\Aevora\
├── aevora\
└── tools\
    └── sprite-studio\
```

A different safe local path is acceptable if documented.

Never commit into the AEVORA repo:

```text
third-party app source
node_modules
Rust target/
installer binaries
Sprite Studio SQLite database
provider credentials
API keys
generated caches
```

---

## 7. Tool A — Sprite Studio

Repository:

```text
https://github.com/JohnKinyanjui/sprite-maker
```

Pin the first evaluation to:

```text
version context: v0.3.3
commit:
9de73a6136a1a045af2e8769349fbadc17dbef69
```

Reason: reproducibility.

Record the inspected license and commit in the report.

---

## 8. Sprite Studio preparation

Before installing anything, audit the machine.

Record versions/status for:

```text
Git
Bun
Rust / cargo
Visual Studio 2022 Build Tools
Desktop development with C++ workload
Codex CLI
Codex authentication status
```

Do not reinstall working prerequisites unnecessarily.

Never put secrets in repo/report.

Expected upstream commands:

```bash
bun install
bun run check
bun tauri dev
```

Native verification:

```bash
cargo test --manifest-path src-tauri/Cargo.toml
cargo clippy --manifest-path src-tauri/Cargo.toml --all-targets -- -D warnings
```

If pinned source requires a documented variation, record it.

---

## 9. Sprite Studio build gate

Required:

```text
[PASS] pinned repo cloned outside AEVORA repo
[PASS] dependencies installed
[PASS] frontend/type checks pass OR failures documented
[PASS] Rust tests pass OR failures documented
[PASS] desktop app launches OR headless MCP operates
```

If an upstream issue blocks generation:

```text
document exact failure
classify environment vs upstream
continue with contract/validator/comparison scaffolding
mark generation phase BLOCKED
```

Do not change AEVORA architecture to work around unrelated upstream defects.

---

## 10. Top Down Sprite Maker status

TDSM is a candidate GUI/product, not a mandatory automatic dependency.

Codex should:

```text
1. detect whether it is already installed/supplied;
2. if available, record version/export capabilities;
3. if unavailable, do not purchase automatically;
4. create a short manual evaluation checklist;
5. prepare import folders for later exports.
```

Valid status examples:

```text
Ready
Installed but not evaluated
Manual user action required
Not available
```

ART-R001 must not fail because TDSM is unavailable.

---

## 11. Aseprite status

Aseprite is expected to be a likely final editing/cleanup/authoritative source-art tool.

Codex should:

```text
detect whether Aseprite is installed
record version if present
record CLI availability if present
```

If absent:

```text
do not purchase automatically
mark "Not installed — production-role candidate"
```

Prepare the pipeline so future `.aseprite` sources can become authoritative without changing the Godot runtime contract.

---

## 12. R&D folder structure

Create:

```text
art/rnd/art_r001/
├── README.md
├── brief/
│   └── aevora_base_human_v0.md
├── candidates/
│   ├── sprite_studio/
│   ├── tdsm/
│   └── aseprite/
├── exports/
├── metadata/
└── review/
```

Do not place experimental originals under:

```text
art/vendor/craftpix/
```

---

## 13. Candidate identity

Use:

```text
Registry/R&D ID: ARTCHAR-R001
Human-readable: AEVORA Base Human v0
slug: aevora_base_human_v0
status: rnd_candidate
```

Do not silently overwrite `CHAR-001`.

---

## 14. Original character brief

Create:

```text
art/rnd/art_r001/brief/aevora_base_human_v0.md
```

Minimum brief:

```text
Original human adventurer / settlement resident
AEVORA 3/4 top-down visual language
pixel-art readability
64×64 technical frame
full body
neutral practical clothing
simple boots
no weapon
no backpack required
no copyrighted-character resemblance
transparent background
stable proportions from every direction
```

Avoid locking detailed lore, faction clothing or final protagonist identity.

This is a pipeline test character.

---

## 15. Visual priorities

Use established AEVORA direction:

```text
3/4 Top-Down Hybrid
square-grid gameplay
dimensional character presentation
pixel / semi-pixel richness
not true diamond isometric
```

Prioritize:

```text
clear silhouette
readable head/body/legs
stable proportions
consistent identity
clean hard pixels
limited unnecessary subpixel detail
```

Do not optimize for maximum detail.

---

## 16. Frame contract — locked for R&D

```text
technical frame = 64×64
background = real transparency
```

Do not:

```text
auto-crop each frame
trim transparent borders independently
auto-center by opaque bbox
rescale individual frames
```

Every frame keeps the same 64×64 canvas.

---

## 17. Root/pivot contract

For direct comparison use the R&D target:

```text
pivot/root target = (32,44)
```

Important:

> `(32,44)` is a comparison baseline, not a permanent AEVORA art lock.

If the candidate clearly needs another physically coherent root, do not silently change it. Measure, report, compare, and request review.

---

## 18. Direction contract

Canonical semantic directions:

```text
down
left
right
up
```

Preferred ART-R001 sheet row order:

```text
row 0 = down
row 1 = left
row 2 = right
row 3 = up
```

Runtime mapping must remain explicit in metadata.

Do not promote row-order assumptions to global engine rules.

---

## 19. Animation contract — ART-R001 only

Create only:

```text
Idle
Walk
```

First evaluation target:

```text
Idle = 4 frames / direction
Walk = 6 frames / direction
```

Initial normalized comparison timing:

```text
150 ms / frame
```

This is R&D cadence, not a permanent animation standard.

If Sprite Studio generates a different mechanically good source loop, preserve original source and make a normalized comparison export separately.

---

## 20. Normalized evaluation sheets

Preferred:

```text
idle.png
256×256
4 columns × 4 rows of 64×64

walk.png
384×256
6 columns × 4 rows of 64×64
```

Separate directional strips are allowed as intermediate source.

Normalized comparison export must follow the grid above.

---

## 21. Metadata contract

Create:

```text
art/rnd/art_r001/metadata/aevora_base_human_v0.json
```

Minimum content:

```json
{
  "id": "ARTCHAR-R001",
  "slug": "aevora_base_human_v0",
  "status": "rnd_candidate",
  "frame_size": [64, 64],
  "pivot": [32, 44],
  "direction_rows": {
    "down": 0,
    "left": 1,
    "right": 2,
    "up": 3
  },
  "states": {
    "idle": {
      "frames": 4,
      "duration_ms": 150,
      "loop": true
    },
    "walk": {
      "frames": 6,
      "duration_ms": 150,
      "loop": true
    }
  }
}
```

Also record:

```text
tool
tool_version/commit
source_workflow
provider/model if generation is used
generation date
source/master paths
normalization notes
```

Never store credentials.

---

## 22. Generated asset provenance

If an AI provider is used, record:

```text
provider
model
tool version/commit
exact character prompt
generation settings
frame policy
rig-only / AI polish / redraw mode
manual edits
normalization steps
```

Preserve prompt/provenance under:

```text
art/rnd/art_r001/metadata/
```

Generated art remains:

```text
prototype candidate
not automatically final-commercial-approved
```

---

## 23. Sprite Studio experiment

If build gate passes, create the first actual candidate through the pinned tool.

Stages:

```text
1. Generate one master character
2. Review master at 1× and 2×
3. Establish root/anchor
4. Create Idle
5. Create Walk
6. Normalize/export to AEVORA contract
```

Do not generate dozens of states.

---

## 24. Master approval gate

Before animation, master must satisfy:

```text
[PASS] readable human anatomy
[PASS] readable at gameplay scale
[PASS] original identity
[PASS] no obvious protected-character resemblance
[PASS] body fits 64×64 safely
[PASS] enough transparent movement margin
[PASS] plausible feet/root location
```

If it fails, revise master first.

---

## 25. Runtime asset validator

Create:

```text
tests/art_r001_asset_contract_test.gd
```

Validate:

```text
file exists
PNG decodes
sheet dimensions
64×64 cells
transparent background exists
pixel-art-safe alpha
no unintended sheet padding
required direction rows
expected frame counts
metadata paths valid
pivot inside frame
timing explicitly declared
```

Also report per frame:

```text
opaque bounding box
visible body width/height
bottommost opaque pixel
left/right transparent safety margin
top safety margin
```

Do not recenter frames from these measurements.

Measurements are evidence only.

---

## 26. Identity/continuity review

Create a visual review sheet showing:

```text
Idle all four directions
Walk representative frames from all four directions
```

Review:

```text
head-size drift
hair/clothing drift
limb-length drift
body-width drift
palette drift
feet/root jitter
directional identity mismatch
```

Record findings.

---

## 27. Godot comparison scene

Create:

```text
scenes/dev/art_r001_character_comparison.tscn
```

Do not replace the normal Player.

The scene must show:

```text
Craftpix technical benchmark
vs
ARTCHAR-R001 candidate
```

under equivalent scale/root/camera conditions.

---

## 28. Comparison scene layout

Include:

```text
1× logical-scale preview
2× inspection preview or equivalent zoom
light ground
dark/contrast ground
root/pivot guide
64×64 canvas guide
```

Do not enlarge only one candidate.

---

## 29. Comparison controls

Suggested:

```text
1 = Idle
2 = Walk

Arrow keys = direction
Space = pause/play

F1 = root/pivot guide
F2 = 64×64 bounds
F3 = background/contrast toggle
```

Different shortcuts are allowed if documented.

---

## 30. Comparison metrics

Use 1–5 only as an R&D aid.

Evaluate:

| Category | Meaning |
|---|---|
| Identity consistency | Same character across directions/frames |
| Gameplay readability | Clear at 1× / actual game presentation |
| Root stability | No unwanted world-position jitter |
| Animation quality | Motion reads and loops coherently |
| Pixel cleanliness | No blur/resample damage |
| Editability | Human artist can repair efficiently |
| Layer potential | Future hair/clothes/equipment separation |
| Reproducibility | Workflow can be repeated |
| Automation potential | Validation/export can be scripted |
| Production effort | Time/manual correction |
| Legal/provenance clarity | Sources/history traceable |

Do not automatically approve final art from score.

---

## 31. Tool evaluation matrix

Report:

| Tool | Availability | Executed? | Strength | Limitation | Recommendation |
|---|---|---:|---|---|---|
| Sprite Studio | ... | Yes/Blocked | ... | ... | ... |
| Top Down Sprite Maker | ... | Optional | ... | ... | ... |
| Aseprite | ... | Optional | ... | ... | ... |

Do not fake evaluation of a tool that was never run.

ART-R001 can succeed with Sprite Studio executed and honest readiness statuses for TDSM/Aseprite.

---

## 32. Optional TDSM import

If the user supplies a TDSM export:

```text
art/rnd/art_r001/candidates/tdsm/
```

Run the same validator and comparison harness.

If none is supplied:

```text
TDSM visual comparison = Pending Manual Export
```

---

## 33. Optional Aseprite import

If Aseprite is available and a candidate is manually edited:

- preserve `.aseprite` source;
- export normalized PNG separately;
- never flatten/delete editable source merely because Godot needs PNG.

If unavailable, leave pending.

---

## 34. No runtime promotion

ART-R001 must not automatically replace the current Craftpix runtime Player.

End state:

```text
Craftpix = current technical runtime benchmark
ARTCHAR-R001 = R&D candidate
```

Promotion requires explicit user review.

---

## 35. Screenshots/evidence

Produce where generation succeeds:

```text
docs/screenshots/art-r001-master.png
docs/screenshots/art-r001-idle-4dir.png
docs/screenshots/art-r001-walk-4dir.png
docs/screenshots/art-r001-godot-comparison.png
docs/screenshots/art-r001-root-guides.png
```

If generation is blocked, produce all possible evidence and mark missing outputs as blocked.

---

## 36. Effort log

Record approximate:

```text
environment setup time
generation time
number of master attempts
number of animation attempts
manual normalization time
manual correction time
validation time
```

The purpose is production-efficiency comparison.

---

## 37. Git hygiene

Before commit:

```text
git status
```

Separate:

```text
ART-R001 authored changes
pre-existing unrelated changes
external-tool files that do not belong in repo
```

Do not commit:

```text
Sprite Studio source checkout
node_modules
target
SQLite DB
credentials
temporary caches
unnecessary large scratch
```

---

## 38. Verification

Run where applicable:

```text
existing DEV-R001..R001.3 regressions
ART-R001 asset contract test
comparison scene smoke test
PNG/source validation
```

ART-R001 must not regress gameplay.

---

## 39. Detailed report

Create:

```text
docs/reports/art-r001-character-asset-production-rnd.md
```

Required sections:

```text
Scope
Starting repo state
External tool versions
Sprite Studio pinned commit
Machine prerequisites
Install/build result

TDSM readiness
Aseprite readiness

Character brief
Generation workflow
Prompt/provenance
Master attempts

Normalized asset contract
Measured frame geometry
Pivot/root findings
Identity consistency findings

Godot comparison result

Tool evaluation matrix
Time/effort observations

Problems / failed attempts
Deviations from handoff
Lessons learned

Recommended production pipeline
What should be tested next
```

---

## 40. WORKLOG update

Add only a concise section, e.g.:

```markdown
## ART-R001 character asset production R&D

- Established isolated 64×64 character-production R&D pipeline without replacing the validated runtime Player.
- Evaluated Sprite Studio at pinned commit <sha>; TDSM/Aseprite readiness recorded honestly.
- Created and validated ARTCHAR-R001 Base Human v0 Idle/Walk candidate where tooling allowed.
- Added Godot side-by-side comparison and automated asset-contract checks.
- Full report: `docs/reports/art-r001-character-asset-production-rnd.md`.
```

Do not duplicate the full report.

---

## 41. Acceptance criteria

ART-R001 is complete when:

```text
[PASS] DEV-R001.3 runtime baseline remains intact
[PASS] external tools isolated from AEVORA repo
[PASS] Sprite Studio pinned to commit 9de73a6...
[PASS] prerequisite/tool versions recorded
[PASS] no credentials committed

[PASS] TDSM availability/status recorded honestly
[PASS] Aseprite availability/status recorded honestly
[PASS] no automatic purchase performed

[PASS] art/rnd/art_r001 structure exists
[PASS] original AEVORA Base Human v0 brief exists
[PASS] candidate is not copied/styled from Craftpix source art

[PASS] normalized frame = 64×64
[PASS] four directions explicit
[PASS] Idle target = 4 frames/direction
[PASS] Walk target = 6 frames/direction
[PASS] normalized timing = 150 ms/frame
[PASS] original source output preserved separately

[PASS] metadata JSON exists
[PASS] provider/model/prompt provenance exists if AI used

[PASS] asset-contract validator exists
[PASS] validator reports geometry / alpha / bbox / pivot evidence

[PASS] dedicated Godot comparison scene exists
[PASS] benchmark and candidate use equivalent scale/root conditions
[PASS] normal main scene is not promoted to candidate art

[PASS] comparison evidence exists where generation succeeds
[PASS] tool evaluation matrix contains no fabricated testing

[PASS] existing gameplay regressions pass
[PASS] detailed ART-R001 report exists
[PASS] WORKLOG gets concise ART-R001 summary
[PASS] no CONTEXT.md is created
```

---

## 42. Required Codex final response

Return:

1. implementation commit SHA;
2. AEVORA parent HEAD;
3. external Sprite Studio path;
4. pinned Sprite Studio version/commit;
5. prerequisite versions/status;
6. build/test result;
7. TDSM status;
8. Aseprite status;
9. ARTCHAR-R001 master result;
10. Idle result;
11. Walk result;
12. normalized sheet paths;
13. metadata path;
14. validator result;
15. pivot/root measurements;
16. Godot comparison result;
17. screenshots;
18. tool evaluation summary;
19. effort/time summary;
20. problems/deviations;
21. recommended next ART handoff.

---

## 43. Stop condition

Stop after ART-R001.

Do not automatically continue to:

```text
Run
Sword
Attack
Walk Attack
Run Attack
Hurt
Death
Tools
Equipment system
NPC generator
runtime Player replacement
```

The user must first review:

```text
visual identity
gameplay readability
root stability
pipeline effort
tool suitability
```

---

## Final intent

ART-R001 should leave AEVORA with evidence, not assumptions.

At the end we should be able to answer:

```text
Can Sprite Studio produce a usable original 64×64 AEVORA base character?

How much cleanup does it require?

Would Top Down Sprite Maker help modular production?

Is Aseprite worth adopting as the authoritative editor?

Can all candidate outputs enter Godot through one stable asset contract?
```

Only after that should the final character-production pipeline be chosen.
