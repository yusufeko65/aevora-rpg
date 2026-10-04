# Sprite Studio originals

`master_down_ai_original.png` preserves the untouched 1254×1254 ImageGen output produced through pinned Sprite Studio / Codex / ChatGPT. `master_down.png` is the fixed 64×64 technical master (one global initial reduction/placement, hard alpha and upstream import cleanup). These are actual generated art, not validator fixtures. Exact history/hashes/prompt are in `../../metadata/provenance.json`.

Initial master reviewed at 1×/2×: readable anatomy/silhouette, neutral original identity, 18×39px opaque bbox, margins L/R=23px, top=6px, bottom=19px, opaque soles Y=44. Benchmark soles are Y=43; comparison pivot remains (32,44), pending art review rather than hidden adjustment. Automatic north-facing inference is incorrect for this visually down-facing master; explicit semantic metadata takes precedence.

Four actual master directions are available, with each untouched AI original preserved separately. Left/right/up retain the same whole-canvas transform, not independent bbox fitting; opaque soles are Y46/Y46/Y45. Their visible palettes (380/359/397 colors) differ from down (44), requiring artist review rather than hidden normalization.

Native source `frames/` contains ONLY four down Idle and six down Walk64×64 PNGs, original7FPS. All ten are distinct, unchanged full canvases. Other directions failed pinned native anatomy preflight; their rejected JSON rig definitions/diagnostics are preserved under `rigs/` and `../../review/native-direction-preflights.json`, not accepted animation. Full normalized Idle/Walk sheets remain BLOCKED (30missing frames). Never duplicate static masters, relabel down or invent render results to fill them.

Database, executable, provider credentials and third-party source stay outside AEVORA. This candidate is not final-commercial-approved or runtime-promoted.
