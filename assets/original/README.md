# Original asset subset

This directory is a deliberately bounded, source-faithful working set for the
Godot recreation. Every asset is a direct byte copy of a locally exported
original asset except the five `stage/tree_*.png` files: these are lossless,
transparent FFDec raster renders of their preserved local source vectors.
Nothing was downloaded, redrawn, cropped, or re-encoded.

The complete preservation export remains outside the project at
../../../original-assets/ffdec. The source-to-destination record is
manifest.json.

## Layout

- maps/ — the five original container timeline renders (stage 1 through 5).
- stage/ — the root-timeline night-sky backdrop, direct island/pipe exports, preserved tree SVGs, and FFDec-rendered tree PNGs for clean layouts.
- player/ — individual Player body frames, all twelve weapon frames, and the original muzzle-flash frame.
- enemies/ — all thirteen composite Enemy wrapper frames, with the original 124x170 registration canvas intact.
- sprites/ — player, enemy, friendly, building-dock, and teleporter renders.
- buildings/ — the seven BuildingOnly artwork states.
- pickups/ — original bitmap-data exports for gameplay projectiles and drops.
- ui/ — original menu renders, cursor layers, the controls HUD, and all six Tutorial frames.
- audio/ — all 21 named original MP3 exports, including both music tracks.
- fonts/ — three embedded fonts used by the original interface.

## Important integration notes

The stage PNGs are full Flash timeline renders, not tile maps. They preserve
the original island layout and initial rubble placements, but also bake in
some dynamic presentation such as the initial player marker. Use them as
faithful visual references or temporary backdrops; rebuild collision,
interactive buildings, player, and UI as independent Godot nodes.

For clean stage composition, draw stage/sky_gradient.png across the screen,
then overlay the oversized transparent stage/sky_stars.png and
stage/distant_islands.png source layers with their recovered parallax offsets.
This is the original Flash composition and prevents the bright one-pixel edge
artifacts in the flattened stage/background.png from looking like a repeated
sky tile. Keep background.png as an import fallback/reference rather than
tiling it. Then use stage/island_452.png, island_634.png,
island_639.png, pipe_627.png, pipe_630.png, and the per-stage tree_*.png
assets with the exact placement data in scripts/stage_layout_data.gd. The
matching tree_*.svg files are retained unchanged as the source-faithful
vector exports. The PNGs are transparent, lossless FFDec 26.2.1 shape
renders made directly from DefineShape2 characters 624, 631, 635, 636, and
640 in `../../../content/farm.maxgames.com/Reign of Centipede FIXEDMTYxNw==.swf`;
they are provided because Godot's SVG import
does not reliably reproduce FFDec's embedded bitmap-pattern fills. Both
forms, their hashes, and raster dimensions are recorded in manifest.json.

Likewise, the composited sprite renders retain their Flash canvas bounds and
transparent padding. Do not trim or crop them when matching original pivots.
The ordinary enemy files deliberately use their direct body-symbol exports
rather than the large parent Enemy registration canvas. The `enemies/`
directory additionally preserves all thirteen `DefineSprite 262 Enemy`
wrapper frames as `enemy_01.png` through `enemy_13.png`, in direct source
frame order. Each is a 124x170 direct copy with its source origin at
approximately `(61.5, 83.05)` and must not be trimmed; use those when matching
the original Enemy's visual scale or registration. Recreate health bars as UI
nodes; enemy_flying.png is the small-flying body symbol.

The `player/` files are the source components for a live, mouse-aimed Player:
`body_standing.png` and `body_walk_01.png` through `body_walk_03.png` are
DefineSprite 566 frames 1 through 4. `weapon_01.png` through
`weapon_12.png` are the labelled frames of DefineSprite 338 in original
weapon-menu order (pistol through bazooka), and `muzzle_flash.png` is
DefineSprite 315 frame 1. Their original transparent canvases and source
registration points are preserved and documented in manifest.json; use them
as independent, rotating layers rather than baking a gun into the body.

`ui/controls_hud.png` is the complete direct `DefineSprite 661` frame-1
export, including its 641x447 source canvas. The six direct Tutorial exports
are in `ui/tutorial/tutorial_01.png` through `tutorial_06.png`, corresponding
to `DefineSprite 561 Tutorial` frames 1 through 6. These UI exports are
reference/presentation assets: preserve their transparent canvases and draw
live HUD values as independent runtime text and bars where interaction is
needed. Their exact sources, hashes, and dimensions are recorded in
manifest.json.

The five `ui/menu_*.png` files are the direct MainMenu frame exports in
original order (main, credits, loss, win, and stage select). Their unusually
large transparent canvases are intentional: place them at the recovered
native offset `(-337, -31)` in the 650x450 viewport rather than scaling or
centering them.

The subset includes the active gameplay frames required for an initial
faithful build. Original multi-frame animation exports not copied here remain
available locally in ../../../original-assets/ffdec/sprites.
