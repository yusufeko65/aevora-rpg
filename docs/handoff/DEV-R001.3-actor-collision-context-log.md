# DEV-R001.3 — Actor Collision Matrix & Boar Blocking

**AEVORA • Godot 4 • Craftpix Asset-First Baseline**

Status: **Implementation handoff — focused corrective pass**  
Parent implementation reviewed: `4170ce8e714baa116d08068b17439e82decd5cd3`

> Revision note: the previous proposal to introduce `CONTEXT.md` has been cancelled.  
> AEVORA will continue using:
>
> - `WORKLOG.md` for concise chronological summaries.
> - `docs/reports/*.md` for detailed implementation reports.

---

# 1. Purpose

DEV-R001.3 has one technical goal:

> **Fix the remaining issue where the Player can pass through the ambient Boar.**

This pass also formalizes the collision-layer contract so future actors do not rely on mixed prototype bitmasks.

Do not expand gameplay systems in this handoff.

---

# 2. Verified Cause of Player ↔ Boar Pass-Through

Current Player scene uses the Godot defaults:

```text
Player collision_layer = 1
Player collision_mask  = 1
```

Current Boar scene explicitly uses:

```text
Boar collision_layer = 4
Boar collision_mask  = 2
```

Current environment bodies were authored using mixed bitmasks such as:

```text
environment collision_layer = 3
```

In Godot, integer `3` means:

```text
Layer 1 + Layer 2
```

So the current prototype behaves like:

```text
Player mask 1
→ sees environment layer bit 1

Boar mask 2
→ sees environment layer bit 2

Player does not see Boar layer 4
Boar does not see Player layer 1
```

Therefore Player and Boar passing through each other is expected from the current collision matrix.

This is **not** a sprite-size or collider-size problem.

---

# 3. Clean Collision Layer Contract

Replace the mixed-layer workaround with an explicit collision matrix.

Use these Godot physics layers:

```text
Layer 1 = Player
Layer 2 = Environment
Layer 3 = Fauna
```

Bitmask values:

```text
Player      = 1
Environment = 2
Fauna       = 4
```

Required baseline:

```text
Player:
  collision_layer = 1
  collision_mask  = 6   # Environment(2) + Fauna(4)

Environment:
  collision_layer = 2

Boar / Fauna:
  collision_layer = 4
  collision_mask  = 3   # Player(1) + Environment(2)
```

Result:

| Actor | Environment | Player | Fauna |
|---|---|---|---|
| Player | collide | — | collide |
| Boar | collide | collide | not required yet |

Do not add fauna-vs-fauna collision yet unless required by a real test.

---

# 4. Environment Layer Cleanup

Current environment bodies may still use values such as:

```text
collision_layer = 3
```

which means they are placed simultaneously on Player and Environment layers.

DEV-R001.3 must migrate active static environment bodies to:

```text
collision_layer = 2
```

Audit at minimum:

```text
House
Fence pieces
Tree trunks
World boundaries
Any other StaticBody2D used by the current test map
```

Do not change their collision geometry.

This handoff changes only collision-layer classification.

Preserve all DEV-R001.2 fence tuning exactly.

---

# 5. Player Collision Setup

Set Player explicitly instead of relying on defaults.

Required:

```text
collision_layer = 1
collision_mask  = 6
```

Keep the existing Player feet collider:

```text
size     = 10×6
position = (0,-1)
```

Do not enlarge the Player collider merely to make Boar blocking more obvious.

---

# 6. Boar Collision Setup

Keep Boar on the Fauna layer:

```text
collision_layer = 4
```

Change:

```text
collision_mask = 2
```

to:

```text
collision_mask = 3
```

so Boar sees:

```text
Player + Environment
```

Keep the existing Boar feet collider unchanged:

```text
size     = 16×8
position = (0,-2)
```

unless a separate verified collision defect requires adjustment.

---

# 7. Expected Player ↔ Boar Behavior

Normal movement:

```text
Player walks into Boar
→ Player is blocked or slides naturally
→ no pass-through
```

```text
Player runs into Boar
→ Player is blocked or slides naturally
→ no pass-through
```

Ambient Boar movement:

```text
Boar walks into Player
→ Boar is blocked / stops / slides naturally
→ no pass-through
```

Do not add avoidance/pathfinding.

---

# 8. Moving Sword Attack vs Boar

DEV-R001.2 already implements:

```text
Sword Attack
Sword Walk Attack
Sword Run Attack
```

Walk/Run Attack move the Player root through `move_and_slide()`.

They must therefore respect the new Fauna collision.

Required:

```text
Walk Attack toward Boar
→ movement blocked by Boar
→ attack animation continues
→ attack completes exactly once
→ no penetration / teleport
```

```text
Run Attack toward Boar
→ movement blocked by Boar
→ attack animation continues
→ attack completes exactly once
→ no penetration / teleport
```

Do not add:

```text
damage
hitbox
hurtbox
knockback
Boar reaction
Boar hurt
Boar death
```

This remains **physical actor blocking only**.

---

# 9. Contact Must Not Trigger Combat

Player↔Boar collision means only:

```text
solid world occupancy
```

It must not imply:

```text
hostility
damage
combat state
aggro
interaction prompt
```

Those systems belong to later design.

---

# 10. Y-Sort / Visual Overlap

Physics collision and rendering order remain separate concerns.

Verify that Player and Boar still Y-sort correctly while approaching each other.

Do not solve rendering order by changing physics layers.

Do not solve collision by changing z-index.

---

# 11. F2 Collision Debug

F2 must clearly show:

```text
Player feet collider
Boar feet collider
Environment colliders
```

At Player↔Boar contact:

```text
colliders may touch
but must not materially overlap
```

Use the debug capture to verify actual contact geometry.

---

# 12. Collision Tests

Add deterministic Player/Boar collision tests.

## 12.1 Player into stationary Boar

Test:

```text
Player → Boar from left
Player → Boar from right
Player → Boar from above
Player → Boar from below
Player → Boar diagonally
```

Required:

```text
no pass-through
```

## 12.2 Boar into stationary Player

Test Boar movement toward Player from several directions.

Required:

```text
no pass-through
```

## 12.3 Walk Attack into Boar

Verify:

```text
walk_attack begins
root advances
root becomes blocked by Boar
animation continues
animation finishes once
state returns correctly
```

## 12.4 Run Attack into Boar

Verify the same behavior.

Do not retune Run Attack timing/distance in this handoff.

---

# 13. Regression Tests

Collision-layer cleanup must not break:

```text
Player vs house
Player vs fence
Player vs tree
Player vs world boundary

Boar vs environment

open gate traversal
corrected fence corners/caps

Arrow movement
WASD secondary aliases

Idle
Walk
Run

Sword Attack
Sword Walk Attack
Sword Run Attack

1280×720 display configuration
```

Do not change DEV-R001.2 fence geometry.

---

# 14. Documentation Workflow

AEVORA will continue using the existing two-document execution workflow.

## 14.1 WORKLOG.md

`WORKLOG.md` remains the concise chronological project log.

For DEV-R001.3 add only a short section such as:

```markdown
## DEV-R001.3 delivered actor collision correction

- Replaced mixed collision-layer setup with explicit Player / Environment / Fauna layers.
- Player and Boar now block each other during normal movement and moving attacks.
- Existing collider geometry, animation mappings and DEV-R001.2 fence tuning remain unchanged.
- Regression tests passed.
- Full details: `docs/reports/dev-r001-3-actor-collision.md`.
```

Do not duplicate the full technical report inside WORKLOG.

---

# 15. Detailed Execution Report

Create:

```text
docs/reports/dev-r001-3-actor-collision.md
```

The report is the detailed execution record.

It should include:

```text
Parent commit
Result commit
Files changed

Starting collision matrix
Final collision matrix

Why pass-through occurred

Environment layer migrations

Player → Boar test results
Boar → Player test results
Diagonal collision result

Walk Attack → Boar result
Run Attack → Boar result

Any sliding/contact observations

Regression test results

Screenshots

Problems encountered / failed attempts
Deviations from handoff
Lessons learned
Known issues / deferred items
Recommendation for next step
```

This is where detailed reasoning belongs.

Do **not** create `CONTEXT.md`.

---

# 16. Documentation Rule for Future Codex Work

For future implementations:

Before coding:

```text
1. Read the new handoff.
2. Read the latest relevant WORKLOG sections.
3. Read only the detailed reports referenced by the handoff or needed for the task.
4. Inspect current code.
```

After coding:

```text
5. Run validation/tests.
6. Create/update the corresponding detailed docs/reports/*.md.
7. Add a concise summary to WORKLOG.md.
8. Commit implementation + report + WORKLOG update together.
```

This avoids three copies of the same information.

---

# 17. Asset / License Tracking

Do not modify the current prototype asset policy.

Craftpix prototype assets remain tracked through:

```text
ART-002 → 11 License & Replacement Ledger
art/vendor/craftpix/PROVENANCE.md
```

No new third-party assets are required for DEV-R001.3.

---

# 18. Scope — Do Not Expand

Do not implement:

```text
Boar AI/pathfinding
Boar combat
health
damage
knockback
hitboxes/hurtboxes
animal interaction
animal taming
inventory
NPC
additional fauna
map expansion
sprite-maker integration
Aseprite pipeline
```

Those are separate decisions.

---

# 19. Required Capture

Produce at least:

```text
docs/screenshots/dev-r001-3-player-boar-collision.png
```

Requirements:

```text
1280×720
F2 enabled
Player and Boar visibly stopped at contact
feet colliders visible
```

Optional:

```text
docs/screenshots/dev-r001-3-run-attack-boar-block.png
```

---

# 20. Acceptance Criteria

DEV-R001.3 is complete when:

```text
[PASS] Player collision_layer explicitly = 1
[PASS] Player collision_mask = Environment + Fauna

[PASS] active environment collision bodies use layer 2 only

[PASS] Boar collision_layer = Fauna
[PASS] Boar collision_mask = Player + Environment

[PASS] Player cannot walk through Boar
[PASS] Player cannot run through Boar
[PASS] Boar cannot walk through Player
[PASS] diagonal Player/Boar contact does not tunnel

[PASS] Sword Walk Attack cannot pass through Boar
[PASS] Sword Run Attack cannot pass through Boar
[PASS] blocked moving attack completes exactly once

[PASS] house collision regression passes
[PASS] fence collision regression passes
[PASS] tree collision regression passes
[PASS] world boundary regression passes
[PASS] gate remains passable
[PASS] Boar environment collision remains working

[PASS] Idle / Walk / Run unchanged
[PASS] all three Sword Attack families unchanged visually

[PASS] player pivot remains (32,44)
[PASS] Player feet collider remains 10×6
[PASS] Boar feet collider remains 16×8 unless separately justified

[PASS] 1280×720 collision capture produced

[PASS] docs/reports/dev-r001-3-actor-collision.md created
[PASS] WORKLOG.md receives concise DEV-R001.3 summary
[PASS] no CONTEXT.md introduced

[PASS] automated tests pass
```

---

# 21. Required Codex Final Report

At completion report:

1. commit SHA;
2. exact final collision-layer/mask matrix;
3. environment bodies migrated from the mixed layer configuration;
4. Player→Boar collision test results;
5. Boar→Player collision test results;
6. diagonal collision result;
7. Walk Attack→Boar result;
8. Run Attack→Boar result;
9. sliding/contact behavior observed;
10. regression test counts/results;
11. screenshot paths;
12. report path;
13. WORKLOG section added;
14. problems or deviations encountered;
15. lessons learned;
16. recommended next handoff.

---

# 22. Recommended Next Step

Stop after DEV-R001.3 for review.

If the R001 technical slice is stable after actor collision correction, treat the **R001 prototype foundation as technically validated**.

Then choose one explicit next track:

```text
Track A — Asset Production R&D
Aseprite
Top Down Sprite Maker
Sprite Studio
→ test original AEVORA 64×64 asset-production pipeline

or

Track B — Gameplay Foundation
→ select the next core gameplay system deliberately
```

Do not start either track automatically.

---

# Final Instruction

Fix the collision matrix, not the sprite art.

Preserve all validated DEV-R001.2 behavior:

```text
64×64 Player
(32,44) pivot
Arrow controls
1280×720 presentation
fence tuning
Sword Attack
Sword Walk Attack
Sword Run Attack
ambient Boar
```

Documentation remains deliberately simple:

```text
HANDOFF
= what should be done

WORKLOG
= concise chronological summary

docs/reports
= detailed implementation evidence and lessons
```

Do not create `CONTEXT.md`.
