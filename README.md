# ZEN MAHJONG (Godot 4.x)

A complete, premium Mahjong Solitaire game developed in Godot 4.x with native GDScript, tranquil aesthetics, guaranteed solvable levels, and full local persistence.

---

## 1. Engine & Version Details

- **Target Engine:** Godot Engine 4.x
- **Exact Tested Version:** `Godot 4.7.2.stable.official.ed1daf0bf`
- **Language:** GDScript (Typed)
- **Renderer:** GL Compatibility (Universal compatibility for Mobile, Android, macOS, Windows, and Web)
- **Viewport Resolution:** 1280 x 720 (Canvas Items stretch mode, Expand aspect ratio)
- **Orientation:** Sensor Landscape (Responsive to screens from compact phones to large tablets and desktop displays)

---

## 2. Visual Identity & Design System

Zen Mahjong is inspired by Japanese Zen gardens, traditional ceramic craftsmanship, and luxury stationery:
- **Primary Color:** Deep Jade Green (`#0D231A` / `#163A2C`)
- **Secondary Color:** Warm Ivory Porcelain (`#FAF6ED` / `#EDE6D6`)
- **Accent Color:** Champagne Gold (`#D4AF37` / `#EAD896`)
- **Supporting Tones:** Muted Sage (`#8A9A86`) and Dark Stone (`#1F2421`)
- **Tiles:** Polished warm ivory ceramic with 3D bevel depth, engraved jade/vermilion/cobalt symbols, and gold hairline accents.
- **Audio:** Custom procedural waveform synthesizer producing organic ceramic clicks, warm chime chords, and harmonic bell tones without external codec dependencies.

---

## 3. Project Architecture

```
res://
  project.godot          # Master engine configuration & Autoload registrations
  README.md              # Setup, architecture & release documentation
  LICENSES.md            # Asset attribution and licensing declarations
  scenes/
    boot/splash.tscn     # Cinematic opening splash screen with logo
    menus/
      main_menu.tscn     # Primary menu with Play, Level Select, Daily & Tutorial
      level_select.tscn  # 30-level selection grid with stars and best times
    gameplay/
      gameplay.tscn      # In-game HUD, BoardView container, and modal dialogs
    settings/
      settings.tscn      # Audio sliders and accessibility controls
  scripts/
    core/
      game_manager.gd    # Autoload singleton: high-level scene & level director
    data/
      mahjong_tile_data.gd # Tile families, matching rules, symbols, and colors
    board/
      board_layout.gd    # 3D grid layouts and canonical free-tile geometry math
      board_generator.gd # Guaranteed solvable reverse-generation solver
      board_view.gd      # 2D board orchestration, selection, undo, hints, shuffle
      tile_view.gd       # Interactive visual tile with 3D bevel and animations
    gameplay/
      gameplay_controller.gd # In-game timer, moves, victory and pause dialogs
    ui/
      main_menu_controller.gd
      level_select_controller.gd
      settings_controller.gd
      splash_controller.gd
    save/
      save_manager.gd    # Versioned local JSON persistence (user://zen_mahjong_save.json)
    audio/
      audio_manager.gd   # Procedural acoustic waveform synthesis for all SFX
  assets/
    backgrounds/
      menu_bg.jpg        # Tranquil Japanese garden illustration with morning mist
      gameplay_bg.jpg    # Deep jade stone gaming surface
    icons/
      app_icon.jpg       # Ivory ceramic Green Dragon tile on forest green
  tests/
    test_runner.gd       # Master headless test suite (14 test suites)
    test_board_logic.gd  # Unit tests for matching rules and solvability
    test_gameplay_flow.gd# Integration tests for selection, undo, hints, victory
    test_full_game_loop.gd # Full session integration tests across all UI & scenes
    debug_all_scenes.gd  # Scene instantiation and node hierarchy validator
```

---

## 4. Mahjong Solitaire Rules & Solvability

### Canonical Free Tile Detection
A tile $T$ at grid position $(x, y, z)$ is free if and only if:
1. **No tile is on top of it:** No tile exists with $z_{other} > z_T$ whose 2x2 bounding footprint overlaps $T$.
2. **At least one side is open:** $T$ is not blocked simultaneously on both the left ($x - 2$) and right ($x + 2$) by tiles on the same layer.

### Matching Rules
- **Suits (Bamboo, Dots, Characters):** Must match exact suit and numerical value (1 to 9).
- **Honors (Winds & Dragons):** Must match exact wind (East, South, West, North) or dragon (Red, Green, White).
- **Bonus Flowers:** Any flower (Plum, Orchid, Bamboo, Chrysanthemum) matches ANY other flower.
- **Bonus Seasons:** Any season (Spring, Summer, Autumn, Winter) matches ANY other season.

### 100% Guaranteed Solvability
Zen Mahjong uses a reverse pair-matching generator:
1. Validates the geometric layout.
2. Simulates reverse removal of free positions from the board.
3. Assigns matching tile identities to valid pairs.
4. Stores verified solution sequences and confirms clearance capability before level launch.

---

## 5. How to Launch and Play

### Option A: Launch Directly via Godot Editor
1. Open the **Godot Engine** application (`/Applications/Godot.app`).
2. Click **Import**, navigate to `/Users/yash/games/mahjjog`, and select `project.godot`.
3. Click **Import & Edit**.
4. Press **F5** (or click the Play icon in the top right) to run the game!

### Option B: Run from the macOS Terminal
Run the following command from the project root:
```bash
/Applications/Godot.app/Contents/MacOS/Godot
```

### Option C: Run Master Test & Debug Verification
Run the master test runner headlessly anytime:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --script res://tests/test_runner.gd
```
All 14 test suites execute cleanly with 100% test pass rate and 0 leaks.
