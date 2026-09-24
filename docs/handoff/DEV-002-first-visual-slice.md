# DEV-002 — First Visual Slice / Codex Handoff

**AEVORA • Replace Greybox with Representative Pixel-Art Prototype**

Purpose: replace the current flat debug/greybox presentation with one small playable scene that already feels like AEVORA, while preserving the working technical foundation from DEV-001. This is a visual vertical slice, not a full DLC-001 map.

## 1. Read Before Editing

Codex must read DEV-001, ART-001 - Visual Direction, DLC-001 - The First Village, and the current Godot project before changing the scene. Existing working movement, collision, camera, interaction, and project structure should be preserved unless a verified defect requires adjustment.

## 2. Primary Goal

The running scene should look like an early-game screenshot of AEVORA rather than a technical diagram. Placeholder assets are allowed, but placeholder presentation is not. Remove large in-world labels such as `PLAYER HOUSE` and replace geometric circles/rectangles with actual pixel-art sprites or tiles.

## 3. Required Scene Composition

Build one compact visual slice around the player's home. Recommended arrangement:

```text
        TREE / VEGETATION LINE

   [PLAYER HOUSE]      [SMALL CROP AREA]
          |                    |
       FENCE / YARD -----------|
          |
================ DIRT ROAD ================
          |
       [BRIDGE]
~~~~~~~~~~~~~~~ RIVER ~~~~~~~~~~~~~~~~~~~~~~
          |
      [TEST NPC / FARMER]
```

The exact coordinates are implementation details. Preserve comfortable walkable space, clear silhouettes, and a believable rural layout instead of forcing perfect symmetry.

## 4. Visual Direction

- Top-down 3/4 pixel-art presentation.
- Warm grounded rural fantasy, tropical/equatorial starter region.
- Natural muted earth palette with selective saturated vegetation accents.
- Buildings should communicate timber, plaster/clay, stone foundation, simple rural craft, and locally available materials.
- Vegetation should feel lush but should not block navigation readability.
- Road edges should be irregular and organic, not one flat rectangular strip.
- Use soft sprite shadows/layering rather than debug outlines or giant labels.
- No cyberpunk/neon visual language in this ordinary village slice.

## 5. Prototype Asset Pack

Use the provided prototype components as visual assets. They are AI-generated temporary assets for layout, scale, atmosphere, and interaction prototyping; they are not final production art. Keep them replaceable behind stable scene/data references.

- `tropical_pixel_village_cottage.png` — primary player-home candidate.
- `pixel_art_thatched_village_cottage.png` — alternate/simple rural building.
- `lush_tropical_pixel_art_tree_sprite.png` — large tropical tree / canopy test.
- `pixel_art_vegetable_garden_plot.png` — visible crop plot.
- `tropical_pixel_fence_corner.png` — yard/farm fencing component.
- `rustic_pixel_art_wooden_bridge.png` — river crossing component.
- `four_direction_villager_sprite_sheet.png` — temporary main-character movement sheet candidate.
- `pixel_farmer_villager_sprite_sheet.png` — temporary farmer/test-NPC sheet.

## 6. Target Repository Paths

Place visual-slice source assets under a clear prototype namespace so they can later be replaced without mixing them with final art:

```text
res://art/prototype/dev_002/
  buildings/
    tropical_pixel_village_cottage.png
    pixel_art_thatched_village_cottage.png
  environment/
    lush_tropical_pixel_art_tree_sprite.png
    pixel_art_vegetable_garden_plot.png
    tropical_pixel_fence_corner.png
    rustic_pixel_art_wooden_bridge.png
  characters/
    four_direction_villager_sprite_sheet.png
    pixel_farmer_villager_sprite_sheet.png
```

Do not rename stable gameplay scenes after these image filenames. Scene/entity IDs should remain conceptual, e.g. `player_home`, `test_farmer`, `bridge_01`.

## 7. Godot Import and Rendering Rules

- Compatibility renderer remains active.
- Disable texture filtering for pixel-art assets; use nearest-neighbor behavior.
- Do not stretch sprites freely to fit the greybox. Choose a consistent prototype scale and keep aspect ratio.
- Pixel scale and 32×32 logical tile baseline remain provisional visual constraints from ART-001. Centralize scale values where possible rather than scattering magic numbers.
- Transparent margins in source images may be cropped or handled via region/atlas workflow if needed, but preserve source PNGs untouched.
- Collision must be independent of visible sprite bounds. A tree collides mainly at the trunk; a building mainly at walls/footprint; canopy/roof can overlap characters visually.

## 8. Layering and Y-Sort

The prototype should establish a reusable draw-order convention. Minimum layers: ground, terrain/road, water, low props/crops, entities, buildings/large objects, canopy/roof foreground, effects/debug. Use Y-sort or an equivalent Godot 4 approach for characters and objects that need depth ordering.

Player and NPC must be able to walk visually behind appropriate tree canopy/building roof portions where the scene design requires it. Do not solve depth by flattening every asset into one background image.

## 9. Ground, Road, River, and Grass

The supplied component pack does not replace the need for basic ground treatment. Codex may create simple temporary pixel tiles for grass, dirt road, river bank, and water if needed, but they must match the visual slice rather than reverting to flat ColorRect-style blocks. Keep these temporary and easy to replace by a formal TileSet later.

- Grass: at least 2–3 subtle variation tiles or sparse detail sprites.
- Road: irregular dirt edge and slight tonal variation.
- River: visible bank transition, water body, and bridge crossing.
- Crop area: use the garden component and ensure the player can visually identify it without text labels.

## 10. Player and NPC Presentation

Replace the current polygon/debug player marker with the temporary villager sprite. Keep the existing `CharacterBody2D`/collision/movement logic. Animation does not need to be production-ready, but movement direction must visibly switch between available directional frames where practical.

Use the farmer sprite for one test NPC. The NPC should remain a reusable NPC scene with its existing interaction contract. Do not bake the NPC into the map image.

## 11. Debug UI Rule

No permanent debug labels inside the playable world. If useful, move technical information to a toggleable debug overlay. Recommended: F1 toggles player position, focused interactable, current zone, collision/debug visibility, and FPS. The normal gameplay screenshot must be clean when debug mode is off.

## 12. Collision Targets

- Player home: block walls/footprint but keep door/front approach reachable.
- Tree: small trunk/root collision, not the entire canopy rectangle.
- Fence: collision follows fence rails/posts with intentional openings.
- Bridge: player can cross only through the bridge path; river bank blocks accidental walking onto water unless future swimming logic exists.
- Crop plot: default recommendation is walkable edge/path with crop rows treated as low obstruction or simple collision only if needed for readability.

## 13. Out of Scope

- Full village map or final DLC-001 geography.
- Final art bible lock or final commercial asset quality.
- Full farming mechanics, seasons, weather, fishing, mining, combat, property system, employee simulation, Knowledge & Inquiry, guild systems, or economy expansion.
- Complex shader work, dynamic global illumination, or effects that require changing away from Compatibility renderer.

## 14. Acceptance Criteria

- The original DEV-001 movement/camera/collision/interaction still works.
- The player is represented by a pixel character, not a debug polygon.
- At least one proper house, crop plot, tree, fence, bridge, river section, road, and NPC are visible in the running scene.
- No giant `PLAYER HOUSE`/`FARM`/`NPC` labels are visible with debug mode off.
- Scene reads immediately as a rural tropical/equatorial life-RPG environment.
- Depth ordering allows believable overlap between character and large environmental assets.
- All image filtering/scaling preserves crisp pixel edges.
- Visual assets live under the prototype asset namespace and can be replaced later without changing gameplay logic.
- Codex captures or reports the final running scene and lists every changed/added file.

## 15. Work Sequence for Codex

Pass 1: inspect current scene and preserve working logic.  
Pass 2: import the DEV-002 asset pack and configure pixel rendering.  
Pass 3: replace player/NPC debug visuals.  
Pass 4: assemble house, yard, crop, road, river, bridge, trees, and fence.  
Pass 5: configure collisions and depth ordering.  
Pass 6: remove permanent debug labels and add optional debug overlay.  
Pass 7: run through Godot MCP, fix parser/runtime/import warnings, then report final screenshot/state before expanding scope.

## 16. Definition of Done

DEV-002 is done when a clean screenshot of the running prototype communicates **“AEVORA rural starting life”** without explanation. The scene does not need final art, but a viewer should no longer mistake it for a debug map. Only after this visual slice is accepted should the project expand into the next gameplay-system handoff.
