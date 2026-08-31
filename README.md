# Reign of Centipede — faithful recreation

This is a runnable Godot 4 / GDScript recreation of the supplied Flash game.
It uses a fixed 30 Hz compatibility simulation, recovered ActionScript data,
and a bounded, hash-traceable subset of locally extracted original assets.
The supplied SWFs under `../content/` are never read or changed at runtime.

## Attribution

The original game, its artwork, audio, and other original assets belong to
their respective creators and rights holders. This is not presented as an
original game by `PerkoL890`.

The recreation implementation in this repository was produced with OpenAI
Codex assistance at `PerkoL890`'s request. `PerkoL890` is publishing the
project rather than claiming personal authorship of the implementation or of
the original game.

## Run locally

Godot 4.7.1 portable is available in this workspace. In PowerShell:

    & 'X:\Reign of Centipede\tools\godot\Godot_v4.7.1-stable_win64.exe' --path 'X:\Reign of Centipede\recreation'

Choose Play, then any Stage 1–5. All stages are intentionally available from
the outset, matching the recovered original.

For a double-click launch, use `../Launch Recreated Game.cmd`. Use
`../Launch Recreated Game with Cheats.cmd` to enable the cheat menu.

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

- Internal viewport: 650 × 450 at a crisp 2× window scale; physics simulation: 30 ticks per second.
- Five fixed-site stages: 12 / 11 / 9 / 6 / 9 construction anchors.
- Direct projectiles, 12 weapons, 13 enemy definitions, four dock types, construction/repair, fighters, carpenters, nurses, crates, balloons, coins, hearts, and win/loss screens.
- No saves, upgrades, demolition, progression locks, ammo, reloads, or modern campaign features were added.

## Project layout

    project.godot                Godot settings and fixed 30 Hz tick
    scenes/Main.tscn             Runtime entry scene
    scripts/game_data.gd         Recovered immutable data and spawn cadence
    scripts/stage_layout_data.gd Recovered Flash timeline placements/bounds
    scripts/main.gd              Menus, simulation, rendering, audio, input
    assets/original/             Direct copied original exports and provenance
    tests/smoke_test.gd          Headless compatibility smoke checks
    docs/compatibility-status.md

The original stage PNGs are baked Flash timeline reference renders, not tile
maps. Runtime instead composes recovered island, pipe, and tree symbols while
creating player, buildings, and UI as live objects. See
`docs/compatibility-status.md` and `assets/original/manifest.json` for the
fidelity boundary and source-to-working-asset mapping.

## Validate

    & 'X:\Reign of Centipede\tools\godot\Godot_v4.7.1-stable_win64.exe' --headless --path 'X:\Reign of Centipede\recreation' --script res://tests/smoke_test.gd
