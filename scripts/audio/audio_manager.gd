extends Node

## Handles game sound effects and ambient music with procedural audio synthesis.

const MAX_SFX_PLAYERS = 8
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0
var streams: Dictionary = {}
var music_tracks: Dictionary = {}
var current_music_track: String = ""
var _music_tween: Tween = null
var _victory_counter: int = 0
var is_muted: bool = false

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "Master"
	add_child(sfx_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Master"
	add_child(music_player)

	for i in range(MAX_SFX_PLAYERS):
		var p = AudioStreamPlayer.new()
		p.name = "SFXPool_%d" % i
		p.bus = "Master"
		add_child(p)
		_sfx_pool.append(p)
	
	_load_sound_assets()
	_load_music_assets()
	_update_audio_settings()
	
	if has_node("/root/SaveManager"):
		var sm = get_node("/root/SaveManager")
		sm.settings_changed.connect(_update_audio_settings)

func _exit_tree() -> void:
	stop_all()

func stop_all() -> void:
	current_music_track = ""
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
		_music_tween = null
	for p in _sfx_pool:
		if is_instance_valid(p):
			p.stop()
			p.stream = null
	if is_instance_valid(music_player):
		music_player.stop()
		music_player.stream = null
	if is_instance_valid(sfx_player):
		sfx_player.stop()
		sfx_player.stream = null

func _update_audio_settings() -> void:
	if not has_node("/root/SaveManager"):
		return
	var sm = get_node("/root/SaveManager")
	var sfx_vol = sm.get_setting("sfx_volume", 1.0)
	var sfx_muted = sm.get_setting("sfx_muted", false)
	is_muted = sfx_muted
	if is_instance_valid(sfx_player):
		sfx_player.volume_db = linear_to_db(sfx_vol) if (not sfx_muted and sfx_vol > 0.01) else -80.0
	
	var music_vol = sm.get_setting("music_volume", 0.8)
	var music_muted = sm.get_setting("music_muted", false)
	if is_instance_valid(music_player):
		if music_muted or music_vol <= 0.01:
			if _music_tween and _music_tween.is_valid():
				_music_tween.kill()
				_music_tween = null
			music_player.volume_db = -80.0
			if music_player.playing:
				music_player.stop()
		else:
			var target_db = linear_to_db(music_vol)
			if _music_tween and _music_tween.is_valid():
				_music_tween.kill()
				_music_tween = null
			music_player.volume_db = target_db
			
			# If unmuted and current track was set but player not playing, resume playback
			if not music_player.playing and not current_music_track.is_empty():
				if music_tracks.has(current_music_track):
					music_player.stream = music_tracks[current_music_track]
					music_player.play()

## Plays the designated background music track with smooth crossfading.
func play_music(track_key: String, crossfade_sec: float = 0.6, force_restart: bool = false) -> void:
	if not music_tracks.has(track_key):
		printerr("[AudioManager] Music track not found: ", track_key)
		return
		
	if not force_restart and current_music_track == track_key and is_instance_valid(music_player) and music_player.playing:
		return
		
	current_music_track = track_key
	var stream = music_tracks[track_key]
	if stream == null or not is_instance_valid(music_player):
		return
		
	music_player.stream = stream
	var sm = get_node_or_null("/root/SaveManager")
	var music_vol = sm.get_setting("music_volume", 0.8) if sm else 0.8
	var music_muted = sm.get_setting("music_muted", false) if sm else false
	
	if music_muted or music_vol <= 0.01:
		if is_instance_valid(music_player) and music_player.playing:
			music_player.stop()
		if _music_tween and _music_tween.is_valid():
			_music_tween.kill()
			_music_tween = null
		return
		
	var target_db = linear_to_db(music_vol)
	
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
		_music_tween = null
		
	if crossfade_sec > 0.05 and music_player.playing:
		_music_tween = create_tween()
		_music_tween.tween_property(music_player, "volume_db", -80.0, crossfade_sec * 0.5)
		_music_tween.tween_callback(func():
			if not is_instance_valid(music_player):
				return
			music_player.stop()
			music_player.stream = stream
			music_player.play()
			var fade_in = create_tween()
			_music_tween = fade_in
			fade_in.tween_property(music_player, "volume_db", target_db, crossfade_sec * 0.5)
		)
	else:
		music_player.stop()
		music_player.stream = stream
		music_player.volume_db = target_db
		music_player.play()

## Selects and plays the appropriate tranquil background track matching the level tier.
func play_music_for_level(level_id: int, is_daily: bool = false, crossfade_sec: float = 0.6) -> void:
	if is_daily:
		play_music("gameplay_novice", crossfade_sec)
		return
	if level_id <= 20:
		play_music("gameplay_novice", crossfade_sec)
	elif level_id <= 40:
		play_music("gameplay_adept", crossfade_sec)
	else:
		play_music("gameplay_master", crossfade_sec)

## Plays the primary Zen Mahjong menu theme.
func play_menu_music(crossfade_sec: float = 0.6) -> void:
	play_music("menu", crossfade_sec)

## Plays a rewarding victory cue (milestone chest fanfare or rotating victory themes).
func play_victory_music(is_milestone: bool = false, crossfade_sec: float = 0.3) -> void:
	if is_milestone and music_tracks.has("victory_milestone"):
		play_music("victory_milestone", crossfade_sec, true)
	else:
		var victory_options = ["victory", "victory_flourish", "victory_resolved"]
		var available: Array[String] = []
		for opt in victory_options:
			if music_tracks.has(opt):
				available.append(opt)
		if available.is_empty():
			if music_tracks.has("victory"):
				play_music("victory", crossfade_sec, true)
		else:
			var chosen = available[_victory_counter % available.size()]
			_victory_counter += 1
			play_music(chosen, crossfade_sec, true)

## Smoothly fades out and stops background music.
func stop_music(fade_sec: float = 0.5) -> void:
	current_music_track = ""
	if not is_instance_valid(music_player):
		return
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
		_music_tween = null
	if fade_sec > 0.05 and music_player.playing:
		_music_tween = create_tween()
		_music_tween.tween_property(music_player, "volume_db", -80.0, fade_sec)
		_music_tween.tween_callback(func():
			if is_instance_valid(music_player):
				music_player.stop()
				music_player.stream = null
		)
	else:
		music_player.stop()
		music_player.stream = null

func get_current_music_track() -> String:
	return current_music_track

func _load_music_assets() -> void:
	var track_paths = {
		"menu": [
			"res://music/Zen Mahjong Menu Theme.mp3",
			"res://assets/music/menu.mp3"
		],
		"gameplay_novice": [
			"res://music/Zen Mahjong Main Theme.mp3",
			"res://assets/music/gameplay_novice.mp3"
		],
		"gameplay_adept": [
			"res://music/Jade Garden Solitaire.mp3",
			"res://assets/music/gameplay_adept.mp3"
		],
		"gameplay_master": [
			"res://music/Sunrise Over the Tile Garden.mp3",
			"res://assets/music/gameplay_master.mp3"
		],
		"victory": [
			"res://music/Zen Mahjong - Peaceful Victory.mp3",
			"res://assets/music/victory.mp3"
		],
		"victory_milestone": [
			"res://music/Zen Mahjong - Level Complete Jingle.mp3",
			"res://assets/music/victory_milestone.mp3"
		],
		"victory_flourish": [
			"res://music/Board Cleared Flourish.mp3",
			"res://assets/music/victory_flourish.mp3"
		],
		"victory_resolved": [
			"res://music/Tiles Resolved Victory Cue.mp3",
			"res://assets/music/victory_resolved.mp3"
		]
	}
	
	for key in track_paths.keys():
		var paths = track_paths[key]
		for path in paths:
			if ResourceLoader.exists(path):
				var stream = load(path)
				if stream != null:
					if stream is AudioStreamMP3:
						var is_ambient_loop = not key.begins_with("victory")
						stream.loop = is_ambient_loop
					music_tracks[key] = stream
					break

func play_sfx(sound_name: String) -> void:
	if is_muted:
		return
	var sm = get_node_or_null("/root/SaveManager")
	if sm and sm.get_setting("sfx_muted", false):
		return
	if streams.has(sound_name) and not _sfx_pool.is_empty():
		var p = _sfx_pool[_sfx_pool_index]
		_sfx_pool_index = (_sfx_pool_index + 1) % _sfx_pool.size()
		p.stream = streams[sound_name]
		var sfx_vol = sm.get_setting("sfx_volume", 1.0) if sm else 1.0
		p.volume_db = linear_to_db(sfx_vol) if sfx_vol > 0.01 else -80.0
		p.play()

func _load_sound_assets() -> void:
	var sound_files = {
		"tile_select": "res://assets/audio/tile_select.wav",
		"tile_match": "res://assets/audio/tile_match.wav",
		"tile_invalid": "res://assets/audio/tile_invalid.wav",
		"hint": "res://assets/audio/hint.wav",
		"shuffle": "res://assets/audio/shuffle.wav",
		"undo": "res://assets/audio/undo.wav",
		"victory": "res://assets/audio/level_complete.wav",
		"level_complete": "res://assets/audio/level_complete.wav",
		"button_click": "res://assets/audio/button_press.wav",
		"button_press": "res://assets/audio/button_press.wav",
		"tile_click": "res://assets/audio/tile_click.wav"
	}
	
	for key in sound_files.keys():
		var path = sound_files[key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream != null:
				streams[key] = stream
				
	# Ensure procedural fallbacks if any asset is missing
	_ensure_fallback_sounds()

func _ensure_fallback_sounds() -> void:
	if not streams.has("tile_click"): streams["tile_click"] = _create_tone(1500.0, 0.04, 0.8, true)
	if not streams.has("tile_select"): streams["tile_select"] = _create_two_tone(880.0, 1320.0, 0.12, 0.7)
	if not streams.has("tile_match"): streams["tile_match"] = _create_chord([523.25, 659.25, 783.99, 1046.50], 0.5, 0.9)
	if not streams.has("tile_invalid"): streams["tile_invalid"] = _create_tone(180.0, 0.08, 0.5, true)
	if not streams.has("hint"): streams["hint"] = _create_chord([880.0, 1108.73, 1318.51], 0.7, 0.8)
	if not streams.has("shuffle"): streams["shuffle"] = _create_noise_sweep(0.3, 0.6)
	if not streams.has("undo"): streams["undo"] = _create_two_tone(600.0, 400.0, 0.08, 0.6)
	if not streams.has("button_click"): streams["button_click"] = _create_tone(1200.0, 0.03, 0.6, true)
	if not streams.has("button_press"): streams["button_press"] = streams["button_click"]
	if not streams.has("victory"): streams["victory"] = _create_arpeggio([523.25, 659.25, 783.99, 1046.50, 1318.51], 0.15, 0.8)
	if not streams.has("level_complete"): streams["level_complete"] = streams["victory"]

# --- Procedural Waveform Synthesis Helpers ---

func _create_tone(freq: float, duration: float, volume: float, sharp_decay: bool = false) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t = float(i) / float(sample_rate)
		var env = exp(-t * (80.0 if sharp_decay else 12.0))
		var sample = sin(2.0 * PI * freq * t) * env * volume
		var int_val = clampi(int(sample * 32767.0), -32768, 32767)
		var byte_idx = i * 2
		data.encode_s16(byte_idx, int_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _create_two_tone(freq1: float, freq2: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t = float(i) / float(sample_rate)
		var env = exp(-t * 15.0)
		var sample = (sin(2.0 * PI * freq1 * t) * 0.6 + sin(2.0 * PI * freq2 * t) * 0.4) * env * volume
		var int_val = clampi(int(sample * 32767.0), -32768, 32767)
		data.encode_s16(i * 2, int_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _create_chord(freqs: Array, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t = float(i) / float(sample_rate)
		var env = exp(-t * 6.0)
		var sample_sum = 0.0
		for f in freqs:
			sample_sum += sin(2.0 * PI * f * t)
		sample_sum = (sample_sum / float(freqs.size())) * env * volume
		var int_val = clampi(int(sample_sum * 32767.0), -32768, 32767)
		data.encode_s16(i * 2, int_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _create_arpeggio(freqs: Array, step_time: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_duration = step_time * freqs.size() + 0.6
	var total_samples = int(sample_rate * total_duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t = float(i) / float(sample_rate)
		var note_idx = mini(int(t / step_time), freqs.size() - 1)
		var note_t = t - (float(note_idx) * step_time)
		var freq = freqs[note_idx]
		var env = exp(-note_t * 5.0)
		var sample = sin(2.0 * PI * freq * t) * env * volume
		var int_val = clampi(int(sample * 32767.0), -32768, 32767)
		data.encode_s16(i * 2, int_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _create_noise_sweep(duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	
	for i in range(total_samples):
		var t = float(i) / float(sample_rate)
		var env = sin(PI * (t / duration))
		var white_noise = rng.randf_range(-1.0, 1.0)
		var sample = white_noise * env * volume * 0.4
		var int_val = clampi(int(sample * 32767.0), -32768, 32767)
		data.encode_s16(i * 2, int_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream
