# Project Technical Audit: Zen Mahjong

## 1. Executive Summary
- **Project Name:** Zen Mahjong
- **Target Engine:** Godot Engine v4.7.2.stable.official (`gl_compatibility` renderer)
- **Primary Platform:** Android (with Desktop and Web export support)
- **Primary Resolution:** 1280 x 720 (Canvas Items stretch mode, expand aspect ratio, sensor-landscape orientation)
- **Main Entry Scene:** `res://scenes/boot/splash.tscn`

---

## 2. Directory & Component Inventory

```
/Users/yash/games/mahjjog/
├── project.godot               # Engine configuration & autoload declarations
├── export_presets.cfg          # Android export settings (Target API 34+, 64-bit arm64-v8a/x86_64)
├── assets/
│   ├── backgrounds/            # Japanese Zen garden porcelain gameplay & menu backgrounds
│   └── icons/                  # 512x512 app icon & store graphical branding
├── scenes/
│   ├── boot/splash.tscn        # Smooth logo fade-in & transition controller
│   ├── menus/main_menu.tscn    # Play, Level Select, Daily Challenge, Settings, Tutorial
│   ├── menus/level_select.tscn # 30-level progression matrix with star ratings & best records
│   ├── settings/settings.tscn  # Audio volume sliders & accessibility toggles
│   └── gameplay/gameplay.tscn  # Interactive Mahjong board, porcelain tiles, HUD, Undo, Hint, Shuffle
├── scripts/
│   ├── audio/audio_manager.gd  # Procedural audio waveform synthesis singleton
│   ├── board/
│   │   ├── board_generator.gd  # Solvable board synthesis with solution paths & verification
│   │   ├── board_layout.gd     # 3D coordinate geometry & 30 layout definitions
│   │   ├── board_view.gd       # 2D viewport rendering, centering, auto-scaling, input dispatcher
│   │   └── tile_view.gd        # Interactive 3D porcelain ceramic tile view & button overlay
│   ├── core/game_manager.gd    # Scene coordinator, active level tracking, daily challenge logic
│   ├── data/mahjong_tile_data.gd # Canonical 144-tile deck, suits, symbols, match rules
│   ├── gameplay/gameplay_controller.gd # HUD, timer, level state, modal dialogs
│   ├── save/save_manager.gd    # JSON persistence for settings, stars, and level unlock progression
│   └── ui/                     # Splash, Main Menu, Level Select, Settings controllers
├── tests/                      # Automated test suite, solvability solvers, playthrough tests
└── reports/                    # Quality assurance & release readiness audit reports
```

---

## 3. Autoload Singletons Verification
In `project.godot`:
1. `SaveManager="*res://scripts/save/save_manager.gd"`
   - Manages persistent state in `user://zen_mahjong_save.json`.
   - Verified: Loads immediately in `_init()` and safely falls back on corrupted JSON data.
2. `AudioManager="*res://scripts/audio/audio_manager.gd"`
   - Synthesizes 9 procedural chimes, clacks, and victory arpeggios on startup.
   - Verified: Volume conversion clamps safely to `-80.0 dB` on zero/mute volume.
3. `GameManager="*res://scripts/core/game_manager.gd"`
   - Coordinates cross-scene transitions and persistent session state.

---

## 4. Resource & Static Analysis Findings

1. **Broken Resource Paths:** None. All `res://` paths in scenes and scripts target existing files on disk.
2. **Missing Dependencies:** All texture imports (`.ctex`) and script UIDs are valid and parsed cleanly.
3. **Unused Files:** Clean repository. Redundant Unity placeholder assets from an earlier repository state were pruned and replaced with Godot 4 assets.
4. **Godot 4 Syntax Compliance:**
   - No deprecated Godot 3 APIs found.
   - Strict adherence to Godot 4 Control anchoring, typing, and stylebox flat styling.
   - All autoload scripts omit `class_name` to prevent Godot 4 singleton shadow warnings.
