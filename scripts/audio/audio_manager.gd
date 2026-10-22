extends Node

## Handles game sound effects and ambient music with procedural audio synthesis.

const MAX_SFX_PLAYERS = 8
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0
var streams: Dictionary = {}

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
	
	_generate_procedural_sounds()
	_update_audio_settings()
	
	if has_node("/root/SaveManager"):
		var sm = get_node("/root/SaveManager")
		sm.settings_changed.connect(_update_audio_settings)

func _exit_tree() -> void:
	stop_all()
	for p in _sfx_pool:
		if is_instance_valid(p):
			p.stream = null
	if is_instance_valid(sfx_player):
		sfx_player.stream = null
	if is_instance_valid(music_player):
		music_player.stream = null
	streams.clear()

func stop_all() -> void:
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
	sfx_player.volume_db = linear_to_db(sfx_vol) if (not sfx_muted and sfx_vol > 0.01) else -80.0
	
	var music_vol = sm.get_setting("music_volume", 0.8)
	var music_muted = sm.get_setting("music_muted", false)
	music_player.volume_db = linear_to_db(music_vol) if (not music_muted and music_vol > 0.01) else -80.0

func play_sfx(sound_name: String) -> void:
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

func _generate_procedural_sounds() -> void:
	streams["tile_click"] = _create_tone(1500.0, 0.04, 0.8, true)
	streams["tile_select"] = _create_two_tone(880.0, 1320.0, 0.12, 0.7)
	streams["tile_match"] = _create_chord([523.25, 659.25, 783.99, 1046.50], 0.5, 0.9)
	streams["tile_invalid"] = _create_tone(180.0, 0.08, 0.5, true)
	streams["hint"] = _create_chord([880.0, 1108.73, 1318.51], 0.7, 0.8)
	streams["shuffle"] = _create_noise_sweep(0.3, 0.6)
	streams["undo"] = _create_two_tone(600.0, 400.0, 0.08, 0.6)
	streams["button_click"] = _create_tone(1200.0, 0.03, 0.6, true)
	streams["victory"] = _create_arpeggio([523.25, 659.25, 783.99, 1046.50, 1318.51], 0.15, 0.8)

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
