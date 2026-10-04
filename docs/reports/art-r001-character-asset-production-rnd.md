# ART-R001 — Character asset production R&D

**Result: R&D/tooling evidence delivered; complete four-direction animation generation BLOCKED.** Four real original masters plus native down Idle4/Walk6 exist. Left/right/up native rigs failed anatomy preflight, so30frames and both normalized sheets are absent. This is a documented generation-blocked exit under handoff§9/§35, not a claim that every asset acceptance criterion passed. No runtime promotion or paid API fallback.

## Scope and starting repository state

Parent AEVORA HEAD: `dfea8e25706cdfdb23e09e00f7532a1f39b68ed4` (`feat : asset`). At start, the only untracked file was the user-supplied ART-R001 handoff; it is not an authored change. No reset or unrelated cleanup. This is an isolated art-pipeline experiment, not DEV-R001.4 and not a final protagonist/art approval. No CHAR-001 replacement, new singleton, gameplay system, normal-main scene replacement or remote push.

Preserved baseline: Godot 4.7.2 Compatibility; logical640×360/native1280×720/exact2× integer display; human64×64; provisional root(32,44); Player feet10×6; speeds48/112px/s; down/left/right/up. Existing vendor PNGs/source mappings/controllers/settings remain unchanged. Craftpix is displayed/measured only as a technical benchmark; none of its images or style were supplied to generation.

## External tools, pin and license

Sprite Studio checkout: `D:/Project/Game RPG/Aevora/tools/sprite-studio`, outside actual AEVORA Git repo. Exact detached pin: `9de73a6136a1a045af2e8769349fbadc17dbef69`, v0.3.3. Local package/Cargo version and MCP server report0.3.3; inspected LICENSE is MIT, copyright2026 John Kinyanjui. Pin remained unmodified. Reference: [official v0.3.3 release](https://github.com/JohnKinyanjui/sprite-maker/releases/tag/v0.3.3).

Node dependencies, Rust target/caches, installers, FFmpeg, tool workspace, SQLite database and provider state all remain outside AEVORA. Headless DB is isolated under `tools/sprite-studio-appdata/com.jakes.sprite-maker/`; `APPDATA` was overridden only for tool processes. No credentials or database in this commit.

## Machine prerequisite audit and installation

| Prerequisite | Initial audit | Final result |
|---|---|---|
| Git | Already working | 2.43.0.windows.1; not reinstalled |
| Bun | Not found | Portable1.4.2 under tools; frozen lockfile install |
| Rust/cargo | Not found | Rust1.99.0(b940084d7), cargo1.99.0(5f94df478), stableMSVC; isolated CARGO_HOME/RUSTUP_HOME, no system PATH change |
| VS2022 Build Tools/C++ | Not detected in PATH/installer/registry audit | Build Tools17.14.41 /17.14.37710.0; VCTools workload, MSVC14.44.35207; vswhere complete/launchable |
| Codex CLI | Already installed | 0.159.2; ChatGPT login confirmed; MCP provider ready |
| Python | Working Python3.12.0/launcher present, but python3 was a Store alias | Existing Codex-bundled Python3.12.14/Pillow12.3.0 used; local py/python3 shims under tools, no interpreter reinstall |
| Node | Existing20.15.0 unsupported by pinned Vite | Existing Codex-bundled24.19.0 used, no Node reinstall |
| FFmpeg | Not found | Official upstream sidecar workflow; N-127142-g12b7b9891b-20261003 |

VS installer exit3010 was recorded; no reboot performed. Later vswhere reports complete/isRebootRequired=false and native linking works. Tool process PATH changes are temporary. Windows SDK root detected via Installed Roots registry. The [official Tauri prerequisites](https://tauri.app/start/prerequisites/) informed C++ requirements; no security setting was disabled.

## Install/build/test gate

- `bun install --frozen-lockfile`: PASS,73 packages.
- `bun run check`: PASS,0 errors/8 unused-CSS warnings in AnimationEditor.svelte.
- `bun run test`: PASS,86 tests/246 assertions.
- Final frontend build with existing bundled Node24: PASS. An earlier unsupported Node20 build failed with missing SvelteKit manifest; an overlapping build was also started, so this failure is not treated as proven upstream breakage. Supported-runtime rerun resolved it.
- `cargo test --manifest-path src-tauri/Cargo.toml --locked`: initial296pass/29fail/1ignored because test helpers hard-code python3 and hit the Store alias. With local shim to existing bundled Python:325pass/0fail/1ignored. The ignored fixture-materialization test is intentionally upstream-ignored, not counted as pass.
- `cargo clippy --manifest-path src-tauri/Cargo.toml --locked --all-targets -- -D warnings`: FAIL,53 diagnostics on lib tests (unused imports/dead code and Clippy lints). Upstream source was not patched or warnings suppressed. This is a documented non-blocking quality-gate failure under the handoff's documented-failure provision, not a clean Clippy pass.
- `cargo build ... --locked --bin sprite-studio-mcp`: PASS(debug). MCP initialize/tools list/status/open workspace/generate operate;48 tools exposed. Desktop GUI launch was not needed or claimed.

External logs are under `D:/Project/Game RPG/Aevora/tools/art-r001-*.log`; concise reproducible evidence is preserved in project metadata/provenance rather than committing caches/log bulk.

## TDSM readiness

Not detected on PATH, standard application locations, limited supplied-download scan or uninstall registry. No user export supplied; status **Pending Manual Export / Manual user action required**. No purchase/install/run or visual score claimed. Import folder/manual checklist prepared. The [official product page](https://flinkerflitzer.itch.io/tdsm) describes style-dependent dimensions/animations/layers and configurable transparent PNG/JSON export; these are published capabilities, not tested AEVORA results. Any later style/export requires separate source/license review.

## Aseprite readiness

**Not installed — production-role candidate**. No executable/CLI found on PATH, standard application/Steam locations or registry; version unavailable, not purchased/run. Prepared import checklist preserves future `.aseprite` files as authoritative editable source with separate PNG exports. [Official CLI documentation](https://www.aseprite.org/docs/cli/) supports the proposed export role; editability/productivity is not measured here.

## Character brief, workflow and provenance

ARTCHAR-R001 / AEVORA Base Human v0 / aevora_base_human_v0 / rnd_candidate. Original text brief: neutral human resident/adventurer, muted teal tunic, warm gray trousers, brown boots, chestnut hair; 3/4 top-down hybrid square-grid view, no locked lore/faction/final protagonist. Transparent fixed64×64 canvas, original identity and readable hard-pixel silhouette. No vendor references.

Sprite-gen guidance informed transparency, fixed-anchor discipline, provider-access confirmation and provenance. Its Python utilities were not executed or substituted for Sprite Studio. User confirmed active ChatGPT image access. Pinned Sprite Studio MCP called Codex/ChatGPT and built-in ImageGen; no paid API fallback. Provider did not expose the image model ID, explicitly recorded as unavailable rather than guessed.

Exact submitted character prompt/settings/requests, original hashes, source paths, tool pin, failed attempts and normalization are in `art/rnd/art_r001/metadata/provenance.json`. First master request:08:44:18–08:47:33UTC,2026-10-04. Untouched original1254×1254 PNG is preserved separately. Initial single-master preparation: whole composition nearest-reduced to64×64, complete raster translated(0,-6), alpha threshold128, then upstream import alpha/orphan cleanup (440→437 opaque pixels, unchanged bbox). This is initial master establishment, **not per-animation-frame bbox normalization**.

The automatic recovery initially indexed the large raw original instead of the technical master. Only the tool workspace manifest file/name was corrected to register the64×64 output; no application source modification. Auto-orient disabled. Upstream measured centroid pivot(31.4988558,44) and incorrectly inferred north at confidence0.529 for a visibly down-facing master. Gameplay comparison remains explicit(32,44); neither inference silently changes geometry or direction.

## Master and animation attempts

Initial down master: anatomy/readability/original-archetype/safe fit reviewed at1×/2×. No obvious protected-character resemblance is observed; this is not legal/commercial clearance. Technical master meets fixed-canvas/alpha/margin gate. It is visibly taller than the Craftpix benchmark at the same scale; body-size/art direction still needs user review.

Source native animation uses pinned bundled rig machinery, no AI polish/redraw. First attempt over-constrained source to6.6666666667FPS; helper rejected non-integer FPS. Handoff allows separate source timing, so source7FPS was selected and preserved; normalized comparison remains150ms. Second prompt was routed as props because its deictic subject omitted "character" and included prop keywords. Explicit HUMAN CHARACTER wording corrected routing without code changes.

Third attempt authored native v3 Idle/Walk rigs. Upstream stopped at its3-validate repair budget and published only four Idle frames with a quality warning. Read-only Walk check actually passed mechanics with six distinct frames/no warnings; one direct invocation of the same pinned bundled renderer completed Walk, no repair, replacement renderer or source patch. Both rigs and10 unchanged source PNGs preserved. Automatic "completed"/budget-finalized status is not treated as final art approval.

One bounded ImageGen attempt per left/right/up master succeeded, using only the original AEVORA down references. Four actual master attempts total across two requests; untouched1254×1254 originals and64×64 technical sources are all preserved/hash-recorded. Same initial complete-composition transform was used for every direction, no independent bbox fitting. All master alpha/margin/anatomy/readability gates pass for a prototype, with root/palette/proportion review explicitly outstanding.

One native-other-directions request authored six v3 rigs, then stopped on left-idle preflight before rendering. Independent read-only native checks confirmed all six failed. Definitions and exact diagnostics are preserved, no speculative repeated repair or replacement renderer:

| Direction/state | Native preflight exit1 |
|---|---|
| Left Idle | Visible neck7.52px from head mask; actual anatomy not segmented there |
| Left Walk | Far-arm/torso overlap10visible pixels without declared parent-child joint |
| Right Idle | Visible neck6.52px from head mask |
| Right Walk | Visible left hip2.55px from torso mask |
| Up Idle | Visible neck6.52px from head mask |
| Up Walk | Far-arm/torso overlap20visible pixels without declared parent-child joint |

This is a **generated rig-fit/native-validation failure**, not a new machine dependency failure or proof the masters cannot be artist-rigged. Rejected direction rig proposals also retain misleading down-facing intent text; they are evidence, never accepted directional animation. Source files were not moved/recentered to disguise failed anatomy. Four animation generation requests total (three down attempts, one other-direction batch); actual successful motion is only down Idle4/Walk6.

Normalized exports: **BLOCKED — NOT PRODUCED** at intended `art/rnd/art_r001/exports/idle.png` and `walk.png`. Source map explicitly lists40required frames;30are missing. The fixed-grid assembler refuses partial atlases, duplicate masters or relabeled down rows. Preserved down originals remain individually reviewable at7FPS source/150ms comparison cadence.

## Normalized asset contract and validation

Metadata: `art/rnd/art_r001/metadata/aevora_base_human_v0.json`. Required sheets: Idle256×256(4×4cells), Walk384×256(6×4cells), rows down0/left1/right2/up3, cells64×64,150ms looping, root(32,44). Source frames retain7FPS timing separately. Fixed-grid assembler copies complete canvases and verifies copied pixel hashes; never trims, crops-to-bbox, interpolates, rescales or nudges individual frames.

`tests/art_r001_asset_contract_test.gd` checks metadata/source references, actual PNG decode, dimensions/no extra sheet padding, all populated cells/rows/counts, hard alpha/transparency/clear borders, explicit pivot/timing and source/provenance. Reports every cell's bbox/visible size/bottom/margins/centroid/palette evidence without recentering. In-memory fixtures exercise valid PNGs plus wrong size/count/padding, opaque/partial alpha, empty rows, missing fields, wrong row/timing/loop and path escapes. Synthetic shapes never become candidate art. Exit0=actual assets pass;1=invalid;2=missing generation, never disguised as pass.

Final asset validator:153self-tests/0failures; actual sheets **BLOCKED**, exit2,2missing outputs and0schema/asset errors. Source validator:117checks/0errors, **BLOCKED**,30missing frames; it verifies the ten real PNGs, hard alpha/margins, distinct pixels, source hashes and authored rig structure, not accepted mechanics for rejected other-direction rigs. Assembly:BLOCKED/30missing/0errors. Master checks:four64×64PNG masters/all hard alpha/nonempty/clear borders PASS. Geometry evidence: `review/direction-master-geometry.json`, `source-contract-report.json`, `down-source-frame-geometry.json`, `native-direction-preflights.json`, `export-assembly.json`, `asset-contract-report.json`. No full-sheet geometry is fabricated.

## Geometry, root and visual continuity findings

Down master bbox[23,6,18,39]; margins L23/R23/top6/bottom19;437opaque/3659transparent pixels; no semitransparent alpha. Native down Idle widths17–20px, Walk17–21px; all heights39px, all opaque bottomsY44, all complete64×64 cells, no alpha/margin failures. Four Idle and six Walk source frames are distinct. Palette43–44colors for Idle and42–44 for Walk; this is observed, not a universal palette cap.

Comparison root remains(32,44). Benchmark planted sole endsY43; candidate sole endsY44 (one-pixel ground convention difference). Idle centroidX31.024–31.883, Walk31.023–32.026; moving silhouette centroid is not physical root drift and is not used to realign. Native Walk contact anchors stayY44, alternate between feet; no accumulated root translation.

Same head/hair/clothing identity retained in down loops. Rigid-part motion shows coarse sleeve/hip joins and lateral silhouette changes; not final polished anatomy or gait. Native mechanical checks do not replace visual review.

| Master direction | Opaque bbox | L/R/top/bottom margin | SoleY / target delta | Visible colors |
|---|---|---|---|---:|
| Down | [23,6,18,39] |23/23/6/19|44 /0|44|
| Left | [25,7,15,40] |25/24/7/17|46 /+2|380|
| Right | [25,8,14,39] |25/25/8/17|46 /+2|359|
| Up | [24,8,16,38] |24/24/8/18|45 /+1|397|

All original masters remain safe/nonempty hard-alpha64×64, but side/back imagery has near one-color-per-visible-pixel palettes versus reduced down palette. Direction identity is broadly consistent (short brown hair, teal practical clothing, gray trousers, brown boots) while head shape/shading density, collar/sleeves and body width drift. Side poses are narrower, though some width change is expected by viewpoint; no silent palette merge or resize. Master-ground switching would move apparent soles1–2px under the fixed comparison root. **Request user review of physically coherent root and body/palette direction before adopting (32,44) as art production guidance.** Across-direction animated root/limb continuity is unmeasured because those clips do not exist.

## Godot comparison and evidence

Dedicated scene: `scenes/dev/art_r001_character_comparison.tscn`. Equivalent root/camera/canvas/filtering for benchmark/candidate;1×logical preview plus2×inspection on light/dark grounds. Native display doubles both equally (2×/4×physical). Controls1Idle/2Walk/arrows direction/Space pause/F1root/F2canvas/F3contrast. Benchmark preserves original12-step Idle timeline/repeated Up cells and6-step Walk. Candidate uses declared mapping, not global row assumptions. Full-sheet validation remains BLOCKED; individually pixel-validated complete down source clips can preview with **NATIVE DOWN ONLY / SOURCE ONLY** labels at150ms comparison cadence. Other directions show their actual neutral master only, clearly MASTER ONLY; no fake motion/relabeled directions. Normal Player is untouched.52comparison smoke checks PASS.

Native1280×720 evidence, logical640×360/exact2×, no image resizing: `art-r001-master.png`, `art-r001-master-4dir.png`, `art-r001-godot-comparison.png`, `art-r001-root-guides.png`, plus DOWN ONLY native source Idle/Walk contact reviews. Requested `art-r001-idle-4dir.png` / `art-r001-walk-4dir.png` exist as **INCOMPLETE evidence**: down shows its actual4/6frames; left/right/up are explicitly BLOCKED, not complete direction-art sheets. Eight captures visually reviewed. Detailed comparison display measurements/modes in `review/display-evidence.json`. Candidate39px-class body is substantially taller than benchmark at equivalent scale; readability is plausible but final gameplay silhouette size needs review.

## Tool evaluation matrix and R&D scoring

| Tool | Availability / executed | Observed strength | Limitation | Recommendation |
|---|---|---|---|---|
| Sprite Studio0.3.3 | Built/MCP/generation/native rigs executed; complete4dir animation BLOCKED | Authenticated original masters, reproducible down native rig output, useful MCP/geometry evidence | Clippy fails; runtime-name assumptions; source recovery/routing/facing heuristics; repair-budget premature finish;6other-direction anatomy failures; rigid seams | Useful supervised R&D, not reliable unattended four-direction/final production yet |
| TDSM | Not available locally / not executed | Published modular/style/export capability only | No supplied export or measured identity/root/edit effort | Pending manual export/checklist; no purchase decision |
| Aseprite | Not installed / not executed | Proposed editable authoritative source/export role only | No hands-on editing/productivity evidence | Production-role candidate after artist-led trial |

Provisional1–5 scores scoped to actual observations: four-master identity3 (recognizable but palette/head/body drift); gameplay readability3 (clear human, scale/face review); root stability down4 / directional masters2 (fixed down contacts but1–2px apparent-ground offsets); animation quality down2 (rigid joins/shuffle), other-direction animation **N/A**; pixel cleanliness down4 / other masters2 (hard alpha, dense noisy palettes); reproducibility3 (pin/rig/hash good, integration corrections required); automation potential2 (strong checks, all six other rigs rejected); provenance traceability4 (original prompt/pin/hashes, model ID unavailable). Editability, layer-production potential and artist-production efficiency **N/A**: no human editing/layer workflow/tool trial measured. No missing-direction animation scores or final art approval inferred.

## Effort observations

Environment from first portable download15:07:51 to operational generation15:44:18local ≈36.5min, excluding earlier untimed audit; Rust first compile8m27s, first tests113s, shim rerun tests40.8s, MCP build26.1s. Master down3m15s plus three-direction batch≈4m45s; four ImageGen master calls total. Native requests≈1m15s/0m30s/2m46s/2m15s, four animation attempts; one direct valid down Walk render≈2s and six rejected diagnostic checks≈2s total. Provider phases≈15min combined, not artist production time. Initial procedural master transform/recovery intervention estimated2–5min; full-sheet normalization attempt ran<2s and stayedBLOCKED, no frame repositioning. Human artist correction0min; rejected anatomy was not fixed or priced as cleanup. Scripted checks/capture CPU runs take seconds-to-minutes; interactive verification/report/harness work is untimed and overlaps installs/generation. Observed tools-to-final-evidence window≈2hours; not an exclusive phase sum or a measured commercial-art productivity estimate.

## Problems, deviations and lessons

- Existing working Git/Codex/Python/Node were not reinstalled. Added only missing prerequisites; runtime-name/version corrections used existing bundled runtimes and process-local launchers.
- Strict Clippy remains failed upstream; source pin untouched. Supported Node build and Python-alias rerun distinguish environment failures from source quality lints.
- Headless MCP satisfied launch gate; no desktop launch claim. Tool workspace DB/credentials/third-party source never enter project history.
- Pinned automatic raw-source recovery, centroid/facing inference and keyword routing are not authoritative art contracts. Explicit metadata and human visual review remain necessary.
- Source FPS must be integer for Python helper; normalized150ms is declared separately. No gameplay timing or speed changed.
- Repair-budget auto-publication may finish incomplete work; inspect actual artifacts/rig diagnostics rather than treating provider "completed" as acceptance.
- One authored source-review capture initially used a nonexistent static hashing API; fixed, stopped only its two failed test processes, reran cleanly. No other editor/game was closed.
- A later comparison update needed an explicit bool for a Variant-derived expression; corrected, stopped only its failed test/capture processes and helpers, then52smoke checks/native captures passed. One manual preflight first placed --check after its path; usage-only diagnostic corrected before recording anatomy results. These are authored/operator errors, not upstream rig failures.
- Tool checkout ownership differs for restricted runner; normal-access read-only Git audit verified exact pin/clean source. No global safe.directory/security bypass added.
- Complete Idle/Walk sheets and30direction frames remain missing. Handoff's documented-blocked generation path is used; acceptance of a complete original four-direction animation candidate is **not** claimed.

## Verification, recommended pipeline and next handoff

Unchanged gameplay regressions: DEV-R0013701 +R001.1 14402 +R001.2 726 +R001.3 4332 =23161checks,0failures. ART validator153self-tests/0failures, source117structural checks/0errors, comparison52checks/0failures; master/direction captures and editor/import checks clean. Real complete-asset status and fixed-grid assembly remainBLOCKED (exit2), not mixed into pass totals. Six failing native anatomy checks are expected evidence, not hidden as successful animation.

Git preflight: authored R&D paths, screenshots/report and concise WORKLOG only; pre-existing user handoff remains untracked. External application source/node_modules/target/installers/SQLite/provider state never staged; no credentials, CONTEXT.md, vendor edits or runtime replacement. Local implementation commit only, no push. Commit SHA is returned after recording this report (not embedded into its own tree).

Recommended pipeline: text brief → one original reviewed master → explicitly reviewed direction sources → fixed-canvas native/artist loops → preserve original timings/editable sources → full-cell atlas + explicit metadata → strict pixel/geometry validation → equivalent-scale Godot visual review → manual acceptance. Avoid blind bbox normalization or heuristics promoted to engine rules. Aseprite's authoritative-editor role and TDSM modular value need a real artist/export trial before commercial/tool-purchase decisions.

Recommended next explicit handoff: **ART-R002 — direction/palette/root review and bounded anatomy-rig repair**, after user review of actual masters/down loops. Establish consistent physical ground/proportions/palette without per-frame bbox normalization; artist-fit joints/masks for one side/back direction, test a bounded native loop, then decide whether Sprite Studio or an Aseprite-authoritative workflow is practical. Optional TDSM manual export uses the same validator. Do not select/purchase/promote tools based on published capability alone. No automatic Run, equipment, attacks, NPC generator or runtime Player promotion. Stop after ART-R001 with reviewable evidence and honest blocked/quality status.
