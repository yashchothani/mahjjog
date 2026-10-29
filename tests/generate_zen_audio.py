import numpy as np
import wave
import struct
import os

SAMPLE_RATE = 44100

def write_wav(filename: str, samples: np.ndarray, sample_rate: int = SAMPLE_RATE):
    # Ensure float in range [-1.0, 1.0]
    samples = np.nan_to_num(samples)
    peak = np.max(np.abs(samples))
    if peak > 0:
        # Normalize to -3.0 dB (approx 0.707)
        target_peak = 0.707
        samples = (samples / peak) * target_peak
        
    # Apply 2ms micro-fade-in and 5ms micro-fade-out to eliminate any pops
    fade_in_len = int(sample_rate * 0.002)
    fade_out_len = int(sample_rate * 0.008)
    if len(samples) > fade_in_len + fade_out_len:
        samples[:fade_in_len] *= np.linspace(0.0, 1.0, fade_in_len)
        samples[-fade_out_len:] *= np.linspace(1.0, 0.0, fade_out_len)
        
    int_samples = np.clip(samples * 32767.0, -32768, 32767).astype(np.int16)
    
    os.makedirs(os.path.dirname(os.path.abspath(filename)), exist_ok=True)
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1) # Mono
        wf.setsampwidth(2) # 16-bit
        wf.setframerate(sample_rate)
        wf.writeframes(int_samples.tobytes())
    print(f"Generated: {filename} ({len(samples)/sample_rate:.2f}s, {len(int_samples)*2} bytes)")

def generate_tile_select() -> np.ndarray:
    """1. TILE SELECT: a soft, delicate ceramic tap with a tiny warm chime (~0.4s)."""
    duration = 0.42
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # 1. Ceramic Tap Transient (stiff porcelain plate modal modes)
    tap_env = np.exp(-t / 0.028)
    tap = (
        0.50 * np.sin(2 * np.pi * 2150 * t) * np.exp(-t / 0.035) +
        0.35 * np.sin(2 * np.pi * 2920 * t) * np.exp(-t / 0.022) +
        0.25 * np.sin(2 * np.pi * 4200 * t) * np.exp(-t / 0.015) +
        0.30 * np.sin(2 * np.pi * 520 * t) * np.exp(-t / 0.040) # Body weight
    ) * tap_env
    
    # Initial 2ms filtered friction click
    noise = np.random.uniform(-1.0, 1.0, n)
    friction = noise * np.exp(-t / 0.004) * 0.20
    
    # 2. Warm Chime Tail (E6 1318.5 Hz + B6 1975.5 Hz + octave)
    chime_env = np.exp(-t / 0.12)
    chime = (
        0.45 * np.sin(2 * np.pi * 1318.51 * t) +
        0.25 * np.sin(2 * np.pi * 1975.53 * t) +
        0.12 * np.sin(2 * np.pi * 2637.02 * t)
    ) * chime_env
    
    return (tap + friction + chime)

def generate_tile_match() -> np.ndarray:
    """2. MATCH SUCCESS: two gentle ivory-tile clicks followed by a satisfying, light crystal chime (~1.3s)."""
    duration = 1.35
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # Click 1 at t = 0.0
    c1_env = np.exp(-t / 0.025)
    c1 = (
        0.50 * np.sin(2 * np.pi * 1850 * t) +
        0.30 * np.sin(2 * np.pi * 2700 * t) +
        0.20 * np.sin(2 * np.pi * 3800 * t) +
        0.30 * np.sin(2 * np.pi * 560 * t)
    ) * c1_env
    
    # Click 2 at t = 0.068s
    dt2 = 0.068
    t2 = np.maximum(0.0, t - dt2)
    mask2 = (t >= dt2).astype(float)
    c2_env = np.exp(-t2 / 0.028) * mask2
    c2 = (
        0.55 * np.sin(2 * np.pi * 2050 * t2) +
        0.35 * np.sin(2 * np.pi * 3100 * t2) +
        0.25 * np.sin(2 * np.pi * 4400 * t2) +
        0.30 * np.sin(2 * np.pi * 620 * t2)
    ) * c2_env
    
    # Light Crystal Chime blooming at t = 0.075s
    # Major chord cluster: G5 (783.99), D6 (1174.66), G6 (1567.98), B6 (1975.53), D7 (2349.32)
    dt_chime = 0.072
    tc = np.maximum(0.0, t - dt_chime)
    mask_c = (t >= dt_chime).astype(float)
    # Gentle swell attack (25ms) then long decay
    swell = np.clip(tc / 0.025, 0.0, 1.0)
    chime_env = swell * np.exp(-tc / 0.38) * mask_c
    
    # Crystal harmonics with slight shimmer detuning
    chime = (
        0.30 * np.sin(2 * np.pi * 783.99 * tc) +
        0.35 * np.sin(2 * np.pi * 1174.66 * tc) +
        0.45 * np.sin(2 * np.pi * 1567.98 * tc) +
        0.40 * np.sin(2 * np.pi * 1975.53 * tc) +
        0.25 * np.sin(2 * np.pi * 2349.32 * tc) +
        0.10 * np.sin(2 * np.pi * 3135.96 * tc) * np.exp(-tc / 0.20)
    ) * chime_env
    
    return c1 * 0.7 + c2 * 0.8 + chime * 0.85

def generate_tile_invalid() -> np.ndarray:
    """3. INVALID MOVE: a quiet, soft wooden tick with no harsh buzzer (~0.18s)."""
    duration = 0.18
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # Damped wooden block modal vibration (soft marimba / rosewood bar)
    # Fundamental mode: 330 Hz, second mode: 880 Hz, third mode: 1540 Hz
    wood_env = np.exp(-t / 0.045)
    wood = (
        0.65 * np.sin(2 * np.pi * 330.0 * t) * np.exp(-t / 0.055) +
        0.30 * np.sin(2 * np.pi * 880.0 * t) * np.exp(-t / 0.030) +
        0.15 * np.sin(2 * np.pi * 1540.0 * t) * np.exp(-t / 0.015)
    ) * wood_env
    
    # Soft felt impact transient
    felt_noise = np.random.uniform(-1.0, 1.0, n) * np.exp(-t / 0.005) * 0.12
    
    return wood + felt_noise

def generate_hint() -> np.ndarray:
    """4. HINT: a delicate high-register bell with a subtle sparkling tail (~1.35s)."""
    duration = 1.35
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # Meditation singing bell / Tibetan tingsha (C7: 2093 Hz with bell inharmonics)
    bell_env = np.exp(-t / 0.35)
    bell = (
        0.60 * np.sin(2 * np.pi * 2093.00 * t) +
        0.25 * np.sin(2 * np.pi * 2093.00 * 2.756 * t) * np.exp(-t / 0.18) +
        0.15 * np.sin(2 * np.pi * 2093.00 * 4.210 * t) * np.exp(-t / 0.10) +
        0.20 * np.sin(2 * np.pi * 1046.50 * t) * np.exp(-t / 0.40) # Warm body subharmonic
    ) * bell_env
    
    # Subtle sparkling tail: gentle celestial pings descending like starlight
    pings = np.zeros(n)
    delays = [0.10, 0.22, 0.35, 0.48]
    freqs = [3135.96, 3951.07, 4700.0, 5587.65] # G7, B7, D8, F8
    for dt_ping, freq in zip(delays, freqs):
        tp = np.maximum(0.0, t - dt_ping)
        mask_p = (t >= dt_ping).astype(float)
        p_env = np.exp(-tp / 0.22) * mask_p
        pings += 0.12 * np.sin(2 * np.pi * freq * tp) * p_env
        
    return bell + pings

def generate_shuffle() -> np.ndarray:
    """5. SHUFFLE: a brief, smooth airy whoosh with tiny ceramic movements (~0.52s)."""
    duration = 0.52
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # 1. Smooth airy whoosh: filtered noise with frequency sweep
    np.random.seed(42)
    raw_noise = np.random.normal(0, 1.0, n)
    
    # Raised cosine envelope for the whoosh
    whoosh_env = (np.sin(np.pi * (t / duration)) ** 2)
    
    # Sweeping bandpass synthesis (additive resonant bands)
    sweep_f = 600.0 + 900.0 * np.sin(np.pi * (t / duration))
    phase = np.cumsum(2 * np.pi * sweep_f / SAMPLE_RATE)
    whoosh = raw_noise * whoosh_env * 0.35 + 0.15 * np.sin(phase) * whoosh_env
    
    # Low-pass smoothing on noise
    kernel_size = 15
    whoosh = np.convolve(whoosh, np.ones(kernel_size)/kernel_size, mode='same')
    
    # 2. Subtle ceramic micro-slides/movements
    slides = np.zeros(n)
    click_times = [0.08, 0.17, 0.26, 0.35, 0.42]
    click_freqs = [2200, 2600, 2900, 2400, 3100]
    for ct, cf in zip(click_times, click_freqs):
        tc = np.maximum(0.0, t - ct)
        mask = (t >= ct).astype(float)
        env = np.exp(-tc / 0.018) * mask
        slides += 0.15 * np.sin(2 * np.pi * cf * tc) * env
        
    return whoosh * 0.75 + slides * 0.45

def generate_undo() -> np.ndarray:
    """6. UNDO: a short, gentle reversed chime followed by a soft click (~0.4s)."""
    duration = 0.40
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    click_time = 0.28
    
    # 1. Reversed chime swell (from t=0.0 to t=0.28)
    t_swell = np.clip(t / click_time, 0.0, 1.0)
    # Exponential swell curve
    swell_env = np.where(t < click_time, (np.exp(3.0 * t_swell) - 1.0) / (np.exp(3.0) - 1.0), 0.0)
    # Swell chime frequencies (A5 880, E6 1318.5, A6 1760)
    chime_swell = (
        0.45 * np.sin(2 * np.pi * 880.0 * t) +
        0.35 * np.sin(2 * np.pi * 1318.51 * t) +
        0.20 * np.sin(2 * np.pi * 1760.0 * t)
    ) * swell_env
    
    # 2. Soft settling click at t = click_time
    tc = np.maximum(0.0, t - click_time)
    mask_c = (t >= click_time).astype(float)
    click_env = np.exp(-tc / 0.030) * mask_c
    click = (
        0.55 * np.sin(2 * np.pi * 1420 * tc) +
        0.35 * np.sin(2 * np.pi * 2350 * tc) +
        0.30 * np.sin(2 * np.pi * 480 * tc)
    ) * click_env
    
    return chime_swell * 0.7 + click * 0.8

def generate_level_complete() -> np.ndarray:
    """7. LEVEL COMPLETE: a warm, elegant three-note musical flourish (~2.1s)."""
    duration = 2.1
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # Three tranquil ascending celestial notes:
    # Note 1: D5 (587.33 Hz) at t = 0.0s
    # Note 2: A5 (880.00 Hz) at t = 0.32s
    # Note 3: D6 (1174.66 Hz) at t = 0.65s (resolving pinnacle octave)
    
    notes_cfg = [
        (0.00, 587.33, 0.85, 0.9),   # t0, freq, decay_s, amp
        (0.32, 880.00, 1.05, 0.95),
        (0.65, 1174.66, 1.45, 1.0)
    ]
    
    total = np.zeros(n)
    for t0, freq, decay, amp in notes_cfg:
        tn = np.maximum(0.0, t - t0)
        mask = (t >= t0).astype(float)
        # Soft 15ms strike attack
        attack = np.clip(tn / 0.015, 0.0, 1.0)
        env = attack * np.exp(-tn / decay) * mask
        
        # Warm celesta / singing bowl harmonics: fundamental + warm 2nd harmonic + pure 4th
        tone = (
            0.60 * np.sin(2 * np.pi * freq * tn) +
            0.28 * np.sin(2 * np.pi * (freq * 2.0) * tn) * np.exp(-tn / (decay * 0.8)) +
            0.12 * np.sin(2 * np.pi * (freq * 3.0) * tn) * np.exp(-tn / (decay * 0.5)) +
            0.08 * np.sin(2 * np.pi * (freq * 4.0) * tn) * np.exp(-tn / (decay * 0.3))
        ) * env * amp
        total += tone
        
    return total

def generate_button_press() -> np.ndarray:
    """8. BUTTON PRESS: a subtle, tactile wooden click (~0.08s)."""
    duration = 0.08
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # Polished teak / bamboo micro-click
    # Low-mid body (520 Hz) + micro crisp snap (2900 Hz, 4400 Hz)
    env = np.exp(-t / 0.016)
    click = (
        0.55 * np.sin(2 * np.pi * 520 * t) * np.exp(-t / 0.022) +
        0.35 * np.sin(2 * np.pi * 2900 * t) * np.exp(-t / 0.007) +
        0.20 * np.sin(2 * np.pi * 4400 * t) * np.exp(-t / 0.004)
    ) * env
    
    # Soft wood contact transient
    friction = np.random.uniform(-1.0, 1.0, n) * np.exp(-t / 0.003) * 0.15
    return click + friction

def generate_tile_click() -> np.ndarray:
    """Delicate single porcelain tile tap (~0.06s)."""
    duration = 0.065
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    env = np.exp(-t / 0.014)
    tap = (
        0.55 * np.sin(2 * np.pi * 2100 * t) * np.exp(-t / 0.018) +
        0.30 * np.sin(2 * np.pi * 3200 * t) * np.exp(-t / 0.010) +
        0.25 * np.sin(2 * np.pi * 480 * t) * np.exp(-t / 0.022)
    ) * env
    return tap

if __name__ == "__main__":
    out_dir = "/Users/yash/games/mahjjog/assets/audio"
    
    sfx_map = {
        "tile_select.wav": generate_tile_select(),
        "tile_match.wav": generate_tile_match(),
        "tile_invalid.wav": generate_tile_invalid(),
        "hint.wav": generate_hint(),
        "shuffle.wav": generate_shuffle(),
        "undo.wav": generate_undo(),
        "level_complete.wav": generate_level_complete(),
        "button_press.wav": generate_button_press(),
        "tile_click.wav": generate_tile_click(),
    }
    
    for fname, data in sfx_map.items():
        fpath = os.path.join(out_dir, fname)
        write_wav(fpath, data)
    print("All Zen Mahjong sound effects generated successfully!")
