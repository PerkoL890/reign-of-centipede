# Compatibility status

## Verification snapshot

The project is a playable Godot 4 recreation driven by recovered ActionScript
values and timeline placement data. It does not run, embed, or modify either
original SWF. The five supplied 1350 × 713 timeline PNGs are retained only as
reference exports: runtime composes clean stages from the original island,
pipe, and tree symbols so it never draws the baked player, rubble, or UI a
second time.

| Area | Status | Evidence / behaviour |
| --- | --- | --- |
| 30 Hz loop and terminal states | Accurate | Fixed tick; loss precedes timer win at wave 66 / tick 58,500 |
| Five stage selection | Accurate | All five original selectable frames; no fabricated unlocks |
| Stage layout | Accurate placement | Recovered PlaceObject2 matrices provide player starts, four island bounds, pipes, 47 build anchors, static tree groups |
| Player traversal | Implemented | Original-speed horizontal motion, gravity/jump, camera dead zone, fall reset/damage, directional pipe pull |
| Weapons and hits | Implemented | Recovered costs, damage, cooldowns, pellet counts, spread, collision order, +1 hit score, and kill rewards |
| Spawn bands and waves | Accurate cadence | Recovered periodic bands, stage-phased docks, special fixed spawns, 61-enemy quirk |
| Shooting fliers and docks | Implemented | Island target / one laser behaviour; off-screen dock travel, occupancy, side attachment, and delayed portal spawning |
| Buildings and friendlies | Implemented | Authored-site purchase, construction/repair, destroyed-to-rubble, defender cadence, fighter/carpenter/nurse roles |
| Pickups and balloons | Implemented | Source launch ranges, gravity/friction, expiry coordinates, linked crate release and landing |
| Original assets/audio | Implemented | Local fonts, sprites, music/effects, clean stage composition, and source-derived gradient/moon/distant-island parallax; SVG tree sources preserved alongside local FFDec PNG renders |
| Persistence/unlocks/demolition | Intentionally absent | The recovered original has none; modernization additions remain deferred |

## Checks performed

- Godot 4.7.1 headless compatibility suite exits 0 with `SMOKE TEST PASS`.
- The suite covers all stage site counts, recovered stage coordinates, both
  pipe directions, source-coordinate special spawns, dock arrival/cadence,
  shooting-flyer targeting, menu-first construction, score/coin rules, wave
  win, and the 61-enemy limit.
- A normal graphical launch and captures of the main menu, stage select,
  tutorial, all five stages, construction/weapon/pause menus, and
  balloon-to-crate release completed without runtime script errors.
- The background regression capture forces a representative camera delta and
  verifies that the oversized source parallax layers remain continuous at the
  viewport borders rather than repeating the flattened root-frame export.
- The original `content` hashes were rechecked after implementation and match
  the reconnaissance records.

## Source quirks retained

- The pistol starts equipped despite its listed $30 price.
- The nominal 60-enemy limit permits 61 because eviction happens only when
  the count is already greater than 60.
- The Medium Shack describes a Mac10 but creates a Desert Eagle defender.
- Nurses create heart pickups rather than using the described beam.
- Dock destruction displays +75 while adding 100 score.
- Flamer and bazooka preserve their recovered projectile-only behaviour; no
  unsupported damage-over-time or area-effect system was invented.

## Deliberate approximation boundary

The baseline is playable and source-driven, but it is not a pixel-for-pixel
Flash VM implementation. These items remain consciously approximate:

- Island collision uses the recovered display bounds rather than Flash's
  exact per-display-object hit-test implementation.
- Original timeline animations, procedural parallax cloud motion, particles,
  screen transitions, cursor expansion, and health-bar artwork are simplified.
- Friendly and ordinary-enemy steering mirrors recovered state rules but is
  not frame-captured against a live Flash runtime.
- Audio uses original files but not Flash positional panning/channel limits;
  forced short process termination can report benign active-audio cleanup
  diagnostics.

Those are fidelity refinements, not missing campaign systems. No modern
progression, saving, upgrades, balance changes, or alternate win condition
has been substituted for recovered original behaviour.
