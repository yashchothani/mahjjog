# Bug & Defect Audit Report: Zen Mahjong

## Bug Classification Summary
- **P0 (Blocker):** 0
- **P1 (Critical):** 4 (All 4 Resolved & Verified)
- **P2 (Major):** 1 (Resolved & Verified)
- **P3 (Minor/Polish):** 2 (Resolved & Verified)

---

### BUG-01: Tile Selection Click Interception by Decorative ReferenceRects
- **Severity:** P1 (Critical - Core gameplay blocked)
- **Observed Behavior:** Clicking or tapping on free tiles on the board did nothing. Tiles could not be picked up or matched.
- **Expected Behavior:** Tapping a free tile selects and elevates it with a gold glowing border; tapping a matching tile clears the pair.
- **Root Cause:** In `scripts/board/tile_view.gd`, `inner_box` and `highlight_border` were instantiated as `ReferenceRect` nodes inside `face_panel`. In Godot 4, `ReferenceRect` inherits `Control` which defaults to `mouse_filter = MOUSE_FILTER_STOP` (0). They spanned the entire tile face, intercepting all mouse events before reaching the tile's click handler.
- **Files Changed:** `scripts/board/tile_view.gd`, `scenes/gameplay/gameplay.tscn`
- **Fix:** Set `mouse_filter = Control.MOUSE_FILTER_IGNORE` on all decorative child nodes. Added a dedicated full-rect transparent `Button` (`ClickButton`) with `CURSOR_POINTING_HAND` that emits `tile_clicked`.
- **Verification Evidence:** `tests/test_tile_button.gd` and `tests/test_play_level1.gd` passed 100%.

---

### BUG-02: Level 2 (Jade Pyramid) Opening Deadlock
- **Severity:** P1 (Critical - Level 2 unwinnable)
- **Observed Behavior:** Level 2 (Jade Pyramid) failed solver solvability validation.
- **Expected Behavior:** Level 2 has multiple free matching pairs at start and is 100% solvable.
- **Root Cause:** In `scripts/board/board_layout.gd`, `create_pyramid_small()` defined a concentric pyramid where every tile on Layer 0 and Layer 1 was covered by the layer above it, and Layer 3 had only 1 single peak tile at `(3, 3, 3)`. At the start of the game, exactly 1 tile was free on the entire board, making any legal pair matching impossible.
- **Files Changed:** `scripts/board/board_layout.gd`
- **Fix:** Redesigned `create_pyramid_small()` into a 34-tile stepped pyramid with exposed outer steps (6x4 base) and a 2-tile peak. Initial free tile count increased from 1 to 14.
- **Verification Evidence:** `tests/debug_layouts_initial_free.gd` and `tests/test_all_30_levels.gd` confirmed proven solvability by solver.

---

### BUG-03: Generated Layouts (Levels 11-30) Duplicate Centerline Coordinates
- **Severity:** P1 (Critical - Odd tile count crash)
- **Observed Behavior:** Levels 11 through 30 failed assertion `Tile count must be even`.
- **Expected Behavior:** All 30 levels have an even number of tiles and valid matching pairs.
- **Root Cause:** In `create_generated_layout()`, random coordinate generation paired `pos_left = (x, y, z)` with `pos_right = (16 - x, y, z)`. When `x = 8`, `pos_left == pos_right == (8, y, z)`. Inserting duplicate keys into `tile_map: Dictionary` caused tile collision, resulting in an odd tile count.
- **Files Changed:** `scripts/board/board_layout.gd`
- **Fix:** Added check `if pos_left != pos_right and not pos.has(pos_left) and not pos.has(pos_right):` to guarantee every symmetry step generates exactly two distinct positions.
- **Verification Evidence:** `tests/test_all_30_levels.gd` verified all 30 levels have even tile counts and 100% solver solutions.

---

### BUG-04: Android Export Failure Due to Missing VRAM Texture Compression
- **Severity:** P1 (Critical - Android builds blocked)
- **Observed Behavior:** Godot headless export failed with `ETC2/ASTC texture compression is required for Android export`.
- **Expected Behavior:** Godot exports a valid Android APK/AAB package.
- **Root Cause:** `project.godot` was missing `textures/vram_compression/import_etc2_astc=true` under `[rendering]`.
- **Files Changed:** `project.godot`, `export_presets.cfg`
- **Fix:** Added `textures/vram_compression/import_etc2_astc=true` in `project.godot` and created standard Android export preset in `export_presets.cfg`.
- **Verification Evidence:** Exported `zen_mahjong.apk` (87MB, arm64-v8a/x86_64) cleanly via `godot --headless --export-debug "Android"`.

---

### BUG-05: Audio Manager Volume Clamping Warning
- **Severity:** P3 (Minor - Console warning)
- **Observed Behavior:** Playing sound effects when `sfx_volume` was 0 produced negative infinity (`-inf`) dB conversion warnings.
- **Expected Behavior:** Audio volume transitions silently to `-80.0 dB` without warning logs.
- **Root Cause:** In `scripts/audio/audio_manager.gd`, `linear_to_db(sfx_vol)` was called directly without clamping zero volumes.
- **Files Changed:** `scripts/audio/audio_manager.gd`
- **Fix:** Updated calculation to `p.volume_db = linear_to_db(sfx_vol) if sfx_vol > 0.01 else -80.0`.
- **Verification Evidence:** `tests/test_runner.gd` passed with zero audio warnings.

---

### BUG-06: Splash Screen Double-Transition on Skip Tap
- **Severity:** P3 (Minor - Redundant scene transition)
- **Observed Behavior:** Tapping the splash screen triggered `change_scene_to_file()` while the automated tween was also scheduled to trigger it.
- **Expected Behavior:** Exactly one scene transition occurs.
- **Root Cause:** Lack of state flag guarding `_go_to_menu()`.
- **Files Changed:** `scripts/ui/splash_controller.gd`
- **Fix:** Added `var _has_transitioned: bool = false` guard.
- **Verification Evidence:** Tested tap input in `tests/debug_all_scenes.gd`.

---

### BUG-07: SaveManager Uninitialized Data on Early Access
- **Severity:** P2 (Major - Race condition on startup)
- **Observed Behavior:** Instantiating `SaveManager` programmatically in scripts or tests accessed uninitialized progress before `_ready()` fired.
- **Expected Behavior:** `SaveManager` has valid loaded data immediately upon creation.
- **Root Cause:** `load_save_data()` was only called in `_ready()`, which does not execute during `_init()` tree creation.
- **Files Changed:** `scripts/save/save_manager.gd`
- **Fix:** Added `load_save_data()` call in `_init()` and provided a clean `reset_to_defaults()` method.
- **Verification Evidence:** `tests/test_save_persistence.gd` passed 100%.
