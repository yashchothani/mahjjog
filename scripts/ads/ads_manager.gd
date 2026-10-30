extends Node

## AdsManager - Centralized Google AdMob controller for Zen Mahjong.
## Integrates Banner, Interstitial, and Rewarded Ads with native Android plugin support
## and safe desktop / test mock fallbacks.

signal initialization_complete
signal banner_loaded
signal banner_failed(error_code: int)
signal interstitial_loaded
signal interstitial_failed(error_code: int)
signal interstitial_closed
signal rewarded_loaded
signal rewarded_failed(error_code: int)
signal rewarded_earned(reward_type: String, amount: int)
signal rewarded_closed

# Production AdMob IDs
const PROD_APP_ID: String = "ca-app-pub-9589033992148693~2059659809"
const PROD_BANNER_ID: String = "ca-app-pub-9589033992148693/4323391294"
const PROD_INTERSTITIAL_ID: String = "ca-app-pub-9589033992148693/5093547480"
const PROD_REWARDED_ID: String = "ca-app-pub-9589033992148693/7781748017"

# Official Google Android Test Ad Unit IDs (protects against accidental invalid traffic during dev)
const TEST_BANNER_ID: String = "ca-app-pub-3940256099942544/6300978111"
const TEST_INTERSTITIAL_ID: String = "ca-app-pub-3940256099942544/1033173712"
const TEST_REWARDED_ID: String = "ca-app-pub-3940256099942544/5224354917"

# Use test ads automatically in debug builds, production ads in release builds
@export var force_test_ads: bool = false

var is_plugin_available: bool = false
var _plugin: Object = null

# Interstitial pacing: show interstitial ad every 3 cleared levels
var levels_cleared_since_last_ad: int = 0
const INTERSTITIAL_FREQUENCY: int = 3

var _pending_reward_callback: Callable = Callable()

func _ready() -> void:
	_init_plugin()

func _use_test_ids() -> bool:
	return force_test_ads or OS.is_debug_build()

func get_banner_ad_unit_id() -> String:
	return TEST_BANNER_ID if _use_test_ids() else PROD_BANNER_ID

func get_interstitial_ad_unit_id() -> String:
	return TEST_INTERSTITIAL_ID if _use_test_ids() else PROD_INTERSTITIAL_ID

func get_rewarded_ad_unit_id() -> String:
	return TEST_REWARDED_ID if _use_test_ids() else PROD_REWARDED_ID

func _init_plugin() -> void:
	if Engine.has_singleton("AdMobPlugin"):
		_plugin = Engine.get_singleton("AdMobPlugin")
		is_plugin_available = true
		print("[AdsManager] Native AdMobPlugin detected!")
		
		# Connect native signals
		if _plugin.has_signal("initialization_complete"):
			_plugin.connect("initialization_complete", _on_native_init_complete)
		if _plugin.has_signal("banner_loaded"):
			_plugin.connect("banner_loaded", _on_native_banner_loaded)
		if _plugin.has_signal("banner_failed_to_load"):
			_plugin.connect("banner_failed_to_load", _on_native_banner_failed)
		if _plugin.has_signal("interstitial_loaded"):
			_plugin.connect("interstitial_loaded", _on_native_interstitial_loaded)
		if _plugin.has_signal("interstitial_failed_to_load"):
			_plugin.connect("interstitial_failed_to_load", _on_native_interstitial_failed)
		if _plugin.has_signal("interstitial_dismissed"):
			_plugin.connect("interstitial_dismissed", _on_native_interstitial_dismissed)
		if _plugin.has_signal("rewarded_loaded"):
			_plugin.connect("rewarded_loaded", _on_native_rewarded_loaded)
		if _plugin.has_signal("rewarded_failed_to_load"):
			_plugin.connect("rewarded_failed_to_load", _on_native_rewarded_failed)
		if _plugin.has_signal("rewarded_user_earned_reward"):
			_plugin.connect("rewarded_user_earned_reward", _on_native_rewarded_earned)
		if _plugin.has_signal("rewarded_dismissed"):
			_plugin.connect("rewarded_dismissed", _on_native_rewarded_dismissed)
			
		_plugin.initialize()
	else:
		is_plugin_available = false
		print("[AdsManager] Running in Desktop/Mock mode (AdMobPlugin not present on this platform)")
		# Preload mock state
		emit_signal.call_deferred("initialization_complete")

func _on_native_init_complete() -> void:
	print("[AdsManager] Native AdMob initialized. Preloading ads...")
	initialization_complete.emit()
	load_interstitial()
	load_rewarded()

# ==============================================================================
#                               BANNER ADS
# ==============================================================================

func load_banner(on_top: bool = false) -> void:
	if is_plugin_available and _plugin:
		_plugin.loadBanner(get_banner_ad_unit_id(), on_top)
	else:
		print("[AdsManager MOCK] load_banner (top=%s)" % on_top)
		banner_loaded.emit()

func show_banner() -> void:
	if is_plugin_available and _plugin:
		_plugin.showBanner()
	else:
		print("[AdsManager MOCK] show_banner")

func hide_banner() -> void:
	if is_plugin_available and _plugin:
		_plugin.hideBanner()
	else:
		print("[AdsManager MOCK] hide_banner")

func _on_native_banner_loaded() -> void:
	banner_loaded.emit()

func _on_native_banner_failed(err_code: int) -> void:
	banner_failed.emit(err_code)

# ==============================================================================
#                            INTERSTITIAL ADS
# ==============================================================================

func load_interstitial() -> void:
	if is_plugin_available and _plugin:
		_plugin.loadInterstitial(get_interstitial_ad_unit_id())
	else:
		print("[AdsManager MOCK] load_interstitial")
		interstitial_loaded.emit()

func is_interstitial_ready() -> bool:
	if is_plugin_available and _plugin:
		return _plugin.isInterstitialLoaded()
	return true

func show_interstitial() -> void:
	if is_plugin_available and _plugin:
		if _plugin.isInterstitialLoaded():
			_plugin.showInterstitial()
		else:
			print("[AdsManager] Interstitial requested but not loaded yet")
			interstitial_closed.emit()
			load_interstitial()
	else:
		print("[AdsManager MOCK] show_interstitial completed")
		interstitial_closed.emit()

func record_level_cleared_for_ads() -> void:
	levels_cleared_since_last_ad += 1
	if levels_cleared_since_last_ad >= INTERSTITIAL_FREQUENCY:
		levels_cleared_since_last_ad = 0
		show_interstitial()

func _on_native_interstitial_loaded() -> void:
	interstitial_loaded.emit()

func _on_native_interstitial_failed(err_code: int) -> void:
	interstitial_failed.emit(err_code)

func _on_native_interstitial_dismissed() -> void:
	interstitial_closed.emit()
	load_interstitial() # Preload next interstitial

# ==============================================================================
#                             REWARDED ADS
# ==============================================================================

func load_rewarded() -> void:
	if is_plugin_available and _plugin:
		_plugin.loadRewarded(get_rewarded_ad_unit_id())
	else:
		print("[AdsManager MOCK] load_rewarded")
		rewarded_loaded.emit()

func is_rewarded_ready() -> bool:
	if is_plugin_available and _plugin:
		return _plugin.isRewardedLoaded()
	return true

func show_rewarded_for_hints(reward_callback: Callable = Callable()) -> void:
	_pending_reward_callback = reward_callback
	if is_plugin_available and _plugin:
		if _plugin.isRewardedLoaded():
			_plugin.showRewarded()
		else:
			print("[AdsManager] Rewarded ad not loaded yet, attempting reload...")
			load_rewarded()
			# If ad is unavailable, fallback nicely so player isn't stuck
			_on_native_rewarded_earned("Hints", 3)
			_on_native_rewarded_dismissed()
	else:
		print("[AdsManager MOCK] Simulating rewarded video ad completion...")
		_on_native_rewarded_earned("Hints", 3)
		_on_native_rewarded_dismissed()

func _on_native_rewarded_loaded() -> void:
	rewarded_loaded.emit()

func _on_native_rewarded_failed(err_code: int) -> void:
	rewarded_failed.emit(err_code)

func _on_native_rewarded_earned(reward_type: String, amount: int) -> void:
	print("[AdsManager] Reward granted: %d %s" % [amount, reward_type])
	rewarded_earned.emit(reward_type, amount)
	if _pending_reward_callback.is_valid():
		_pending_reward_callback.call(reward_type, amount)
		_pending_reward_callback = Callable()

func _on_native_rewarded_dismissed() -> void:
	rewarded_closed.emit()
	load_rewarded() # Preload next rewarded video
