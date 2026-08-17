# Reign of Centipede — faithful recreation

This is a runnable Godot 4 / GDScript recreation of the supplied Flash game.
It uses a fixed 30 Hz compatibility simulation, recovered ActionScript data,
and a bounded, hash-traceable subset of locally extracted original assets.
The supplied SWFs under ../content/ are never read or changed at runtime.

## Run locally

Godot 4.7.1 portable is available in this workspace. In PowerShell:

    & 'X:\Reign of Centipede\tools\godot\Godot_v4.7.1-stable_win64.exe' --path 'X:\Reign of Centipede\recreation'

Choose Play, then any Stage 1–5. All stages are intentionally available from
the outset, matching the recovered original.

For a double-click launch, use `../Launch Recreated Game.cmd`.

## Controls

| Control | Action |
| --- | --- |
| A/D or Left/Right | Move |
| W or Up | Jump |
| Mouse | Aim and fire |
| S or Down | Build/repair nearby, or enter a pipe from its endpoint |
| B | Open the building menu when standing by unused rubble |
| E or the HUD Weapons button | Weapon menu |
| Escape | Pause (or return from Stage Select/Credits) |

Stand beside an existing rubble site, press S/Down or B, choose a blueprint,
then hold S/Down to construct it. Buildings spawn defenders at their recovered
tick intervals. Coins purchase buildings and weapons; score is feedback only.

## Source-compatible baseline

- Internal viewport: 650 × 450 at a crisp 2× window scale; physics simulation:
  30 ticks per second.
- Five fixed-site stages: 12 / 11 / 9 / 6 / 9 construction anchors.
- Victory: wave counter above 65 at tick 58,500 (about 32:30); no boss or
  enemy-clear requirement.
- Clean source-symbol stage composition (islands, pipes, trees, rubble) with
  recovered player/site/collision coordinates—no baked timeline ghosts.
- Direct projectiles, 12 weapons, 13 enemy definitions, four dock types,
  construction/repair, fighters, carpenters, nurses, crates, balloons,
  coins, hearts, and win/loss screens.
- Original quirks retained in data: free starter pistol despite menu price,
  61-enemy source cap, Medium Shack's actual Desert Eagle defender, nurse
  hearts rather than a beam, dock score display mismatch, and non-AOE bazooka
  / non-DOT flamer.
- No saves, upgrades, demolition, progression locks, ammo, reloads, or
  modern campaign features were added.

## Project layout

    project.godot              Godot settings and fixed 30 Hz tick
    scenes/Main.tscn           Runtime entry scene
    scripts/game_data.gd       Recovered immutable data and spawn cadence
    scripts/stage_layout_data.gd Recovered Flash timeline placements/bounds
    scripts/main.gd            Menus, simulation, rendering, audio, input
    assets/original/           Direct copied original exports and provenance
    tests/smoke_test.gd        Headless compatibility smoke checks
    docs/compatibility-status.md

The original stage PNGs are baked Flash timeline reference renders, not tile
maps. Runtime instead composes the recovered original island, pipe, and tree
symbols using `stage_layout_data.gd`, while creating player/buildings/UI as
live objects. See docs/compatibility-status.md for the remaining fidelity
boundary and assets/original/manifest.json for every source-to-working-asset
mapping.

## Validate

Run the compatibility smoke test through Godot:

    & 'X:\Reign of Centipede\tools\godot\Godot_v4.7.1-stable_win64.exe' --headless --path 'X:\Reign of Centipede\recreation' --script res://tests/smoke_test.gd

It verifies stage-coordinate placement, bidirectional pipes, special spawns,
dock arrival/cadence, shooting flyers, construction/defenders, score/coins,
the timer win condition, and the original 61-enemy cap.
