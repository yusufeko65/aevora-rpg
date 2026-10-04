# Craftpix development source subset

These original files were copied byte-for-byte from the user's `07 - Art & Visual` Google Drive folders for DEV-R001 development/testing. They are technical reference assets, not approved final AEVORA art. No PNG has been resized, cropped, recolored or recentered.

ART-001 and ART-002 were read on 2026-10-03, including `01 Asset Master`, `03 Animation & Frame`, `05 Source & License` and `10 Craftpix Source Audit`. The existing LIC-001 row is Pending; commercial/edit/redistribution checks remain unchecked. No claim of a commercial license is made. This handoff authorizes local development/testing only. Do not publish this source subset to a public repository or redistribute it until the relevant pack licenses and proof are verified. No remote push is part of DEV-R001.

TMX files are retained as mapping evidence, not loaded as runtime maps. They reference additional files deliberately omitted from this small subset; they are not standalone complete vendor packs. Runtime dependencies are enumerated in `data/source_mapping/craftpix.json`; byte hashes and decoded PNG measurements are in `craftpix_audit.json`.

## DEV-R001.2 prototype additions (2026-10-04)

The revised handoff records the user's confirmation that these are official free Craftpix downloads and authorizes Sword Walk/Run Attack for this prototype. This does not clear future public/commercial distribution. Preserve **ART-002 → 11 License & Replacement Ledger**: obtain the exact pack's final-use license/proof and approve its intended distribution, or replace the artwork before publication. No remote ledger was modified and no remote Git push is included.

Fourteen original PNGs were fetched from the verified Male source folder through authenticated Drive access, without resizing, cropping, shifting, repainting or generating artwork. Existing `Base_boy.tmx` provides all source timelines and was not edited. Exact decoded dimensions and SHA-256 hashes remain in `data/source_mapping/craftpix_audit.json`. All 42 earlier PNGs and four TMX files retain their baseline hashes.

| DEV-R001.2 original addition | Google Drive source | Source bytes |
| --- | --- | ---: |
| `main_character/male/Sword_Run_Attack_with_shadow.png` | [source](https://drive.google.com/file/d/1uG_AIGb_3ILJfXdz0YU2oPgsi6PmO8YZ/view?usp=drivesdk) | 14268 |
| `main_character/male/Sword_Run_Attack_without_shadow.png` | [source](https://drive.google.com/file/d/1g_yathctMNj5mK2sbBEdfgt75IKOQ8S7/view?usp=drivesdk) | 13284 |
| `main_character/male/Sword_Run_Attack2_sword_back.png` | [source](https://drive.google.com/file/d/1fZ9xIgQOyXu1uwEp9bAoEVgsdARsCERk/view?usp=drivesdk) | 6213 |
| `main_character/male/Sword_Run_Attack3_body.png` | [source](https://drive.google.com/file/d/1Wofd-M_EB7PLHvLjs3oeptuRwRcbQRnY/view?usp=drivesdk) | 9724 |
| `main_character/male/Sword_Run_Attack4_sword_front.png` | [source](https://drive.google.com/file/d/1BRYC2IMg7O-X5HOGh5yRkwNZvqFZ30DB/view?usp=drivesdk) | 6390 |
| `main_character/male/Sword_Run_Attack5_head.png` | [source](https://drive.google.com/file/d/1JzBk7D2AdXqczH7xZmm9PpG4eQZG_PXm/view?usp=drivesdk) | 8268 |
| `main_character/male/Sword_Run_Attack6_swing.png` | [source](https://drive.google.com/file/d/1sl7wz9-BDUp9JyxulTVy2IBCUacS2XEU/view?usp=drivesdk) | 5510 |
| `main_character/male/Sword_Walk_Attack_with_shadow.png` | [source](https://drive.google.com/file/d/1y4AbIPoFL_oKQF7lckHm2bGP0wwpzqAt/view?usp=drivesdk) | 11817 |
| `main_character/male/Sword_Walk_Attack_without_shadow.png` | [source](https://drive.google.com/file/d/17xu-sQVnNm2Rc_sWyf30jYyDFmSxht3X/view?usp=drivesdk) | 10891 |
| `main_character/male/Sword_Walk_Attack2_sword_back.png` | [source](https://drive.google.com/file/d/15J8CSXt5HcU0KHjPQrFr8-zIhWLkVQup/view?usp=drivesdk) | 5691 |
| `main_character/male/Sword_Walk_Attack3_body.png` | [source](https://drive.google.com/file/d/1GYq47fkWMaXVXPMDY-kZX9XJHJq2_nNm/view?usp=drivesdk) | 8266 |
| `main_character/male/Sword_Walk_Attack4_sword_front.png` | [source](https://drive.google.com/file/d/1CehdDMys91-vsSkZET3aRBDmdVl_NbSf/view?usp=drivesdk) | 5802 |
| `main_character/male/Sword_Walk_Attack5_head.png` | [source](https://drive.google.com/file/d/1Ka4JgzbdQHuIbb-d7PzACTtICbzboY05/view?usp=drivesdk) | 7175 |
| `main_character/male/Sword_Walk_Attack6_swing.png` | [source](https://drive.google.com/file/d/1gy8ZzfaO2Fxbt8XkIlqNEQHFsXYuiTb6/view?usp=drivesdk) | 5313 |

### Replacement/compliance status

| Asset group | Current permission | Final release gate | Tracking |
| --- | --- | --- | --- |
| Seven Sword Walk Attack source PNGs above | User-authorized prototype/testing | Pending final-use clearance/proof **or legal final-art replacement** before public/commercial release | ART-002 → 11 License & Replacement Ledger; this provenance and audit |
| Seven Sword Run Attack source PNGs above | User-authorized prototype/testing | Pending final-use clearance/proof **or legal final-art replacement** before public/commercial release | ART-002 → 11 License & Replacement Ledger; this provenance and audit |

Do not remove this record when replacing assets. Retain source attribution and replacement history. Prototype authorization is not a blanket redistribution/commercial-license claim.

## Exact original source files

DEV-R001.1 (2026-10-04) adds the following 13 original files (12 PNGs, 1 TMX), downloaded through the same authenticated Drive workflow. License remains **Pending**, local development/testing only. `Exterior.tmx` is the primary reference; its copy is not imported. The runtime reads only the selected terrain, house/window/roof, and fence layers. Unselected birds/cat/animated-tree references are not runtime dependencies. Door/window and chimney smoke use the exact source static pose, not a new animation system. Runtime source hashes and dimensions are re-audited; no original PNG/TMX was edited.

| DEV-R001.1 addition | Google Drive source |
| --- | --- |
| `main_character/home/Exterior.tmx` | [source](https://drive.google.com/file/d/1vjeEtP1HYssJAWwUO3R6ML-a4WhE2juj/view?usp=drivesdk) |
| `main_character/home/exterior.png` | [source](https://drive.google.com/file/d/1X7Jifl9_hThTUx67vI3vNd-Az57pqLUk/view?usp=drivesdk) |
| `main_character/home/Doors_windows_animation.png` | [source](https://drive.google.com/file/d/1SHMVhSkwfNLei8-_vbnhZeuPUfh0Z6ai/view?usp=drivesdk) |
| `main_character/home/house_details.png` | [source](https://drive.google.com/file/d/13N4sGMykKBRzDo2G7nXaZqC0JnAXm57S/view?usp=drivesdk) |
| `main_character/home/ground_grass_details.png` | [source](https://drive.google.com/file/d/1wwaLX9ZaoFsMCCuY2jn1dlcPCA6h2gvx/view?usp=drivesdk) |
| `main_character/male/Sword_attack_with_shadow.png` | [source](https://drive.google.com/file/d/1_UfcxW5svjOC5RnA4Qv95cBPttqf9uFN/view?usp=drivesdk) |
| `main_character/male/Sword_attack2_sword_back.png` | [source](https://drive.google.com/file/d/1Y540o5DOlVr-Eal3hs4PMAgivmlU3sQg/view?usp=drivesdk) |
| `main_character/male/Sword_attack4_sword_front.png` | [source](https://drive.google.com/file/d/12CanRncTRfeMHG4Chg-NeYwfbyVIzp6v/view?usp=drivesdk) |
| `main_character/male/Sword_attack6_swing.png` | [source](https://drive.google.com/file/d/1m-Gjf_3P39rjRePpfUXCuD6-q7Jd86Vq/view?usp=drivesdk) |
| `main_character/male/Sword_attack5_head.png` | [source](https://drive.google.com/file/d/1CX_cofQG8Y5ajEMdSA9NSNNnU5lXlyCQ/view?usp=drivesdk) |
| `main_character/male/Sword_attack3_body.png` | [source](https://drive.google.com/file/d/17xAwpCHLeCG9vXAzgZIsmRgAGlQzdVp2/view?usp=drivesdk) |
| `main_character/male/Sword_attack_without_shadow.png` | [source](https://drive.google.com/file/d/1acQi38WtWr_78lECWK6XgSG1glEWrWmg/view?usp=drivesdk) |
| `main_character/home/Smoke_animation.png` | [source](https://drive.google.com/file/d/1mEhJigTJdku0nFyejcOV1JMkCUlDQ2fd/view?usp=drivesdk) |

### DEV-R001 preserved subset

| Project-relative file | Google Drive source |
| --- | --- |
| `main_character/male/Base_boy.tmx` | [source](https://drive.google.com/file/d/1A8Q9gmjfdLdaU9SgN99HO_WG3I0zm76L/view?usp=drivesdk) |
| `main_character/male/Unarmed_Walk_with_shadow.png` | [source](https://drive.google.com/file/d/1vfcjUnKLZQB3VAheRUPWEwFT_P3Rzxl5/view?usp=drivesdk) |
| `main_character/male/Unarmed_Run_with_shadow.png` | [source](https://drive.google.com/file/d/1f6EfmsAGznEgu94u8pzzz9oZ2VWJT-_H/view?usp=drivesdk) |
| `main_character/male/Unarmed_Idle_with_shadow.png` | [source](https://drive.google.com/file/d/1NaKH6qN0uGOZWuP1m7-b9t7sxpI0Z-lg/view?usp=drivesdk) |
| `main_character/male/Unarmed_Run1_shadow.png` | [source](https://drive.google.com/file/d/1LPIAnh92gDnkgN67vbjF-Ax_sAjMAn5A/view?usp=drivesdk) |
| `main_character/male/Sword_Idle_without_shadow.png` | [source](https://drive.google.com/file/d/1uI0fFsVryn1DDPpvNOU6eGFTbYFYJqFn/view?usp=drivesdk) |
| `main_character/male/Unarmed_Idle1_shadow.png` | [source](https://drive.google.com/file/d/12TgzxQ1XRUd6cSBdfNI8UpJfXiY-opcj/view?usp=drivesdk) |
| `main_character/male/Unarmed_Walk1_shadow.png` | [source](https://drive.google.com/file/d/1PkTBN8SDlF6pkqQUmvkXgGROg9H57bZM/view?usp=drivesdk) |
| `main_character/male/Sword_Walk5_head.png` | [source](https://drive.google.com/file/d/1cYhzbZFKEJlKEnBTxn86bVh2biCm2fO5/view?usp=drivesdk) |
| `main_character/male/Sword_Walk4_sword_front.png` | [source](https://drive.google.com/file/d/1_De5GViohHCny8fxq_mQPNdOKy_xEk9A/view?usp=drivesdk) |
| `main_character/male/Sword_Walk3_body.png` | [source](https://drive.google.com/file/d/1ASV6mSqUs_CZ7OEtrkEUgdeAQy4cqt1o/view?usp=drivesdk) |
| `main_character/male/Sword_Walk2_sword_back.png` | [source](https://drive.google.com/file/d/1AuV5Iy5D69iaV7PCs71bi83CIQ-7uRF3/view?usp=drivesdk) |
| `main_character/male/Sword_Run5_sword_front.png` | [source](https://drive.google.com/file/d/1YGrU1HtLTBSIjQxxRw7RpEQsd2Pmfpxc/view?usp=drivesdk) |
| `main_character/male/Sword_Run4_head.png` | [source](https://drive.google.com/file/d/1c3ZL0E6Czb5ECASx889EWj9Q7yMKCJQA/view?usp=drivesdk) |
| `main_character/male/Sword_Run3_body.png` | [source](https://drive.google.com/file/d/14MC7mrgAH7ZDTBtWQ9gzmOQbrHF8vhOH/view?usp=drivesdk) |
| `main_character/male/Sword_Run2_sword_back.png` | [source](https://drive.google.com/file/d/1yTXNntetE1nBjei1Iw_597UhUv3f19bm/view?usp=drivesdk) |
| `main_character/male/Sword_Idle5_head.png` | [source](https://drive.google.com/file/d/1pdpmlnZlF_8RQq03nKYjfEEIJSRflSIG/view?usp=drivesdk) |
| `main_character/male/Sword_Idle4_sword_front.png` | [source](https://drive.google.com/file/d/1dtyGG4Q5kMhUUopnm3QVt-UpJ2UW9y5p/view?usp=drivesdk) |
| `main_character/male/Sword_Idle3_body.png` | [source](https://drive.google.com/file/d/10S660mM5WRx3J5tYt2xxV44m2gKDuM9f/view?usp=drivesdk) |
| `main_character/male/Sword_Idle2_sword_back.png` | [source](https://drive.google.com/file/d/1WsUBt4RbHvxwMLNrFPzbh3bkgaR2GB4o/view?usp=drivesdk) |
| `main_character/male/Unarmed_Walk_without_shadow.png` | [source](https://drive.google.com/file/d/1z0MvZTWsLgr3AwbJe5oalVcwX59hVazX/view?usp=drivesdk) |
| `main_character/male/Sword_Run_without_shadow.png` | [source](https://drive.google.com/file/d/1PJZpgxA9vnrJktZMOj3cKjDka3MwSy58/view?usp=drivesdk) |
| `main_character/male/Sword_Walk_without_shadow.png` | [source](https://drive.google.com/file/d/1R1jCA-9p8l7O1R3e3qN7pVpunohwz9vI/view?usp=drivesdk) |
| `main_character/male/Unarmed_Idle_without_shadow.png` | [source](https://drive.google.com/file/d/1d7hudF-OyG2zkxENkvLwf5xlFiZ-6NXV/view?usp=drivesdk) |
| `main_character/male/Unarmed_Run_without_shadow.png` | [source](https://drive.google.com/file/d/1J8hMM-MwbutBq-NSPx0MQQ5yNdfrPV7S/view?usp=drivesdk) |
| `fauna/hunt_animal/Animals.tmx` | [source](https://drive.google.com/file/d/1EKMxO5tZKUMUN1_Rho-huMKN2NihVYQ-/view?usp=drivesdk) |
| `fauna/hunt_animal/Boar_Idle_with_shadow.png` | [source](https://drive.google.com/file/d/12J0HhMOQqQI87WKvf5G11UvpPqCWx0I5/view?usp=drivesdk) |
| `fauna/hunt_animal/Boar_Walk_with_shadow.png` | [source](https://drive.google.com/file/d/1CXT0ApmtHSzTPXiT1JE-Y-32GBdkfqtt/view?usp=drivesdk) |
| `tile/path_and_road/Road1_grass.png` | [source](https://drive.google.com/file/d/1aKWyj908YpThB5h4CBIUC0UNL1c5nWN5/view?usp=drivesdk) |
| `tile/path_and_road/Roads.tmx` | [source](https://drive.google.com/file/d/1uQ3wuFYBrRSo3Hj5JJj5sKA8rkeZmMLV/view?usp=drivesdk) |
| `tile/path_and_road/Ground_grass.png` | [source](https://drive.google.com/file/d/1H0CrN2nROjMtpLlCNEEsYY5G8QKs5MiO/view?usp=drivesdk) |
| `flora/tree/Tree3.png` | [source](https://drive.google.com/file/d/15Iy3-M9bJR4Ib_oWNZMLzFO81-Y2Qo5S/view?usp=drivesdk) |
| `flora/tree/Tree1.png` | [source](https://drive.google.com/file/d/1fQPsC5STtyLUXACv-BGlLtVtJkWAsct6/view?usp=drivesdk) |
