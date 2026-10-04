# ART-R001 isolated character-production experiment

ARTCHAR-R001 / AEVORA Base Human v0 is a prototype candidate, **not** CHAR-001 and not commercial-approved. The normal Player remains Craftpix. No vendor image is an AI/style reference.

## Contract

- Fixed 64×64 transparent cells; provisional comparison pivot (32,44).
- Explicit rows: down=0, left=1, right=2, up=3.
- Idle 4 frames (256×256), Walk 6 frames (384×256), 150ms/frame, looping.
- Never individually crop, recenter by bounding box, rescale, or trim frames. Measurements are read-only evidence. A coherent different root requires review.
- Preserve tool originals separately from normalized exports. Future `.aseprite` files are authoritative editable sources, never disposable export intermediates.

`metadata/aevora_base_human_v0.json` records readiness and intended paths. Missing outputs mean BLOCKED, not successful generation. Run `tests/art_r001_asset_contract_test.gd`; exit 0=real assets pass, 1=invalid contract/assets, 2=missing generation. Its synthetic self-tests only verify the validator, never count as candidate art.

Open `scenes/dev/art_r001_character_comparison.tscn` and run this scene only. 1=Idle, 2=Walk, arrows=direction, Space=pause, F1=root, F2=canvas, F3=contrast. Both sides share scale/root/camera; first panel is 1× logical scale, second is 2× inspection. The normal 1280×720 display doubles both equally. Benchmark Idle preserves its original 12-step TMX timeline including repeated Up cells; candidate Idle remains 4 steps.

Sprite Studio v0.3.3 is isolated at `D:/Project/Game RPG/Aevora/tools/sprite-studio`, pin `9de73a6136a1a045af2e8769349fbadc17dbef69`. Source, dependencies, database, credentials, installers and caches stay outside this Git repo. Detailed results: `docs/reports/art-r001-character-asset-production-rnd.md`.

Final R&D result: four real original masters and native down Idle4/Walk6; complete four-direction exports BLOCKED by six rejected other-direction rigs. Comparison plays validated complete down source clips at the declared comparison150ms cadence with **NATIVE DOWN ONLY** label; left/right/up show their neutral masters, never fake motion. Neither complete normalized sheet nor final commercial approval is claimed. Review source/missing-frame/native-diagnostic JSONs and explicit INCOMPLETE screenshots before choosing the next ART handoff.
