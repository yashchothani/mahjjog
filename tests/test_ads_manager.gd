class_name TestAdsManager
extends RefCounted

## Automated unit test suite for AdsManager and Google AdMob integration.

static func run_tests(context: Object) -> void:
	print("====================================================")
	print("       TESTING GOOGLE ADMOB INTEGRATION             ")
	print("====================================================")
	
	var tree: SceneTree = context if context is SceneTree else (context.get_tree() if context.has_method("get_tree") else null)
	var ads: Node = tree.root.get_node_or_null("AdsManager") if tree else null
	assert(ads != null, "AdsManager singleton must exist in root tree")
	
	# Test 1: Ad Unit IDs validation
	print("[AD TEST 1] Verifying AdMob Unit IDs...")
	assert(ads.PROD_APP_ID == "ca-app-pub-9589033992148693~2059659809", "Production App ID mismatch")
	assert(ads.PROD_BANNER_ID == "ca-app-pub-9589033992148693/4323391294", "Production Banner ID mismatch")
	assert(ads.PROD_INTERSTITIAL_ID == "ca-app-pub-9589033992148693/5093547480", "Production Interstitial ID mismatch")
	assert(ads.PROD_REWARDED_ID == "ca-app-pub-9589033992148693/7781748017", "Production Rewarded ID mismatch")
	print("  -> Production IDs validated successfully!")
	
	# Test 2: Debug vs Release ID resolution
	print("[AD TEST 2] Verifying Test ID safeguard...")
	var banner_id = ads.get_banner_ad_unit_id()
	var inter_id = ads.get_interstitial_ad_unit_id()
	var reward_id = ads.get_rewarded_ad_unit_id()
	if OS.is_debug_build() or ads.force_test_ads:
		assert(banner_id == ads.TEST_BANNER_ID, "Debug mode must use Google Test Banner ID")
		assert(inter_id == ads.TEST_INTERSTITIAL_ID, "Debug mode must use Google Test Interstitial ID")
		assert(reward_id == ads.TEST_REWARDED_ID, "Debug mode must use Google Test Rewarded ID")
		print("  -> Debug safeguard active: using official Google Test Ad IDs")
	else:
		assert(banner_id == ads.PROD_BANNER_ID, "Release mode must use Production Banner ID")
		print("  -> Release mode active: using Production Ad IDs")

	# Test 3: Rewarded Ad Flow & Callback
	print("[AD TEST 3] Testing Rewarded Video Ad Grant...")
	var state = {"granted": false, "amount": 0}
	var callback = func(type: String, amount: int):
		state["granted"] = true
		state["amount"] = amount
		
	ads.show_rewarded_for_hints(callback)
	assert(state["granted"] == true, "Reward callback must be invoked")
	assert(state["amount"] == 3, "Rewarded ad must grant 3 hints")
	print("  -> Rewarded Ad callback executed successfully (+3 hints granted)!")

	# Test 4: Interstitial Ad Pacing
	print("[AD TEST 4] Testing Interstitial Ad Pacing (Every 3 Levels)...")
	ads.levels_cleared_since_last_ad = 0
	ads.record_level_cleared_for_ads()
	assert(ads.levels_cleared_since_last_ad == 1, "Level counter should be 1")
	ads.record_level_cleared_for_ads()
	assert(ads.levels_cleared_since_last_ad == 2, "Level counter should be 2")
	ads.record_level_cleared_for_ads()
	assert(ads.levels_cleared_since_last_ad == 0, "Counter should reset to 0 after triggering ad")
	print("  -> Interstitial pacing confirmed: Triggers every 3 level completions!")

	# Test 5: Banner Show / Hide
	print("[AD TEST 5] Testing Banner lifecycle...")
	ads.load_banner(false)
	ads.show_banner()
	ads.hide_banner()
	print("  -> Banner lifecycle methods executed without errors!")

	print("====================================================")
	print("  ALL GOOGLE ADMOB INTEGRATION TESTS PASSED 100%!   ")
	print("====================================================")
