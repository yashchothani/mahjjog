extends SceneTree

func _init() -> void:
	_run_standalone.call_deferred()

func _run_standalone() -> void:
	run_tests(self)
	quit(0)

static func run_tests(tree: SceneTree) -> void:
	print("--- TESTING LOCALIZATION MANAGER ---")
	
	assert(tree.root.has_node("LocalizationManager"), "LocalizationManager autoload must exist")
	var lm = tree.root.get_node("LocalizationManager")
	var sm = tree.root.get_node("SaveManager") if tree.root.has_node("SaveManager") else null
	
	var langs = lm.get_available_languages()
	print("Found %d supported languages" % langs.size())
	assert(langs.size() == 7, "Must support 7 languages")
	
	# Verify all keys in EN exist in all other languages
	var en_keys = lm.STRINGS["en"].keys()
	print("Total keys in English dictionary: %d" % en_keys.size())
	
	for lang_dict in langs:
		var code = lang_dict["code"]
		assert(lm.STRINGS.has(code), "STRINGS must contain language: %s" % code)
		var missing_keys = []
		for key in en_keys:
			if not lm.STRINGS[code].has(key):
				missing_keys.append(key)
		if missing_keys.size() > 0:
			print("Language %s missing keys: %s" % [code, str(missing_keys)])
		assert(missing_keys.is_empty(), "Language %s must have all translation keys" % code)
		print("Language '%s' (%s) verified 100%% complete!" % [code, lang_dict["native"]])
		
	# Test language switching and persistence
	var tracker = {"fired": false, "code": ""}
	var callable = func(new_lang):
		tracker["fired"] = true
		tracker["code"] = new_lang
	lm.language_changed.connect(callable)
	
	# Determine a language different from current to test switching
	var target_lang = "zh" if lm.get_current_language() != "zh" else "ja"
	lm.set_language(target_lang)
	
	assert(tracker["fired"], "language_changed signal should fire")
	assert(tracker["code"] == target_lang, "Signal should pass new language code")
	assert(lm.get_current_language() == target_lang, "Current language should match target")
	if sm:
		assert(sm.get_setting("language") == target_lang, "SaveManager should persist language setting")
		
	# Switch back to en
	tracker["fired"] = false
	lm.set_language("en")
	assert(tracker["fired"], "language_changed signal should fire when switching back")
	assert(lm.get_current_language() == "en", "Current language should be en")
	assert(lm.get_text("APP_TITLE") == "ZEN MAHJONG", "APP_TITLE in en should be ZEN MAHJONG")
	
	lm.language_changed.disconnect(callable)
	print("--- ALL LOCALIZATION TESTS PASSED! ---")
