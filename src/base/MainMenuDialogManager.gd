extends Control
class_name FPSC_MainMenuDialogManager

@export var ChapterSelectBoxContainer : Control
@export var BonusSelectBoxContainer : Control
@export var ChapterSelectButtonTemplate : FPSC_MainMenuChapterIcon
@export var MainMenuPanel : Control
@export var ChapterSelectPanel : Control
@export var BonusSelectPanel : Control
@export var SettingsPanel : Control
@export var NewGameButton : BaseButton
@export var BonusGameButton : BaseButton
@export var SettingsButton : BaseButton
@export var QuitGameButton : BaseButton
@export var ResumeButton : BaseButton
@export var ChapterSelectAbortButton : BaseButton
@export var BonusSelectAbortButton : BaseButton
@export var SettingsAbortButton : BaseButton
@export var GameNameLabel : Label
@export var GameVersionLabel : Label
@export var ControlsContainer : BoxContainer
@export var MouseSensitivitySlider : Slider
@export var FOVSlider : Slider
@export var ToggleButtonsContainer : Control

var CustomBooleanSettings = {}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	FPSC_ConsoleInstance.stale_mode = Input.MOUSE_MODE_VISIBLE
	ChapterSelectButtonTemplate.visible = false
	for i in range(0,len(FPSC_LevelManager.metadata.Chapters.keys())):
		var btn = ChapterSelectButtonTemplate.duplicate()
		btn.visible = true
		btn.id = i # chapter num
		btn.connect("callback",callback_manager)
		btn.label.text = FPSC_LocalizationSystem.FPSC_GetLocalString("Chapters." + FPSC_LevelManager.metadata.Chapters.keys()[i])
		btn.button.texture_normal = load("res://textures/" + FPSC_LevelManager.metadata.Chapters[FPSC_LevelManager.metadata.Chapters.keys()[i]])
		ChapterSelectBoxContainer.add_child.call_deferred(btn)
	for i in range(0,len(FPSC_LevelManager.metadata.BonusChapters.keys())):
		var btn = ChapterSelectButtonTemplate.duplicate()
		btn.visible = true
		btn.id = i # chapter num
		btn.connect("callback",callback_manager2)
		btn.label.text = FPSC_LocalizationSystem.FPSC_GetLocalString("BonusChapters." + FPSC_LevelManager.metadata.BonusChapters.keys()[i])
		btn.button.texture_normal = load("res://textures/" + FPSC_LevelManager.metadata.BonusChapters[FPSC_LevelManager.metadata.BonusChapters.keys()[i]])
		BonusSelectBoxContainer.add_child.call_deferred(btn)
	NewGameButton.connect("pressed",newgame)
	BonusGameButton.connect("pressed",bonegame)
	SettingsButton.connect("pressed",setgame)
	QuitGameButton.connect("pressed",get_tree().quit)
	ChapterSelectAbortButton.connect("pressed",cancel)
	BonusSelectAbortButton.connect("pressed",cancel)
	SettingsAbortButton.connect("pressed",cancel)
	MouseSensitivitySlider.connect("drag_ended",OnSensitivitySliderModified)
	FOVSlider.connect("drag_ended",OnFOVSliderModified)
	if ResumeButton != null:
		if FPSC_Player.sessionPlayer == null: ResumeButton.visible = false
		ResumeButton.connect("pressed",resumegame)
	if FPSC_Player.sessionPlayer == null:
		# Only add background map if we're actually at the main menu
		var bgm = "res://maps/" + FPSC_LevelManager.metadata.BackgroundMaps[0] + ".tscn"
		add_child(load(bgm).instantiate())
	else:
		MainMenuPanel.baseboard_window_title = "Pause Menu"
	GameNameLabel.text = FPSC_LevelManager.metadata.GameName
	GameVersionLabel.text = FPSC_LevelManager.metadata.Version
	for element in ToggleButtonsContainer.get_children():
		CustomBooleanSettings[element.name] = element.button_pressed
		FPSC_LevelManager.set(element.name,element.button_pressed)
	if not FileAccess.file_exists("user://gameconfig.mconf"):
		var sfa = FileAccess.open("user://gameconfig.mconf",FileAccess.WRITE)
		var sinputmap = {}
		for i_name in InputMap.get_actions():
			sinputmap[i_name] = InputMap.action_get_events(i_name)
		sfa.store_var([sinputmap,FPSC_LevelManager.sensitivity,FPSC_LevelManager.fov,CustomBooleanSettings],true)
		sfa.close()
	var fa = FileAccess.open("user://gameconfig.mconf",FileAccess.READ)
	var multivar = fa.get_var(true)
	var inputmap = multivar[0]
	FPSC_LevelManager.sensitivity = multivar[1]
	MouseSensitivitySlider.value = multivar[1]
	if len(multivar) > 2:
		FPSC_LevelManager.fov = multivar[2]
	if len(multivar) > 3:
		for key in multivar[3]:
			ToggleButtonsContainer.get_node(str(key)).button_pressed = multivar[3][key]
	fa.close()
	for key in inputmap.keys():
		InputMap.action_erase_events(key)
		for value in inputmap[key]:
			InputMap.action_add_event(key,value)
	for setting in ControlsContainer.get_children():
		var s_name = setting.text.split(" - ")[0]
		var event = InputMap.action_get_events("p_" + setting.name)[0]
		var keystring = ""
		if event is InputEventKey:
			var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			keystring = OS.get_keycode_string(keycode)
			if keystring == " ": keystring = "[SPACE]"
		if event is InputEventMouseButton:
			keystring = "[MOUSE" + str(event.button_index) + "]"
		setting.text = s_name + " - " + keystring + " (Click to rebind)"
		bindval[s_name] = setting
		setting.connect("pressed",startKeybindSetting.bind(s_name))

var bindval = {}

func newgame():
	MainMenuPanel.visible = false
	ChapterSelectPanel.visible = true

func bonegame():
	MainMenuPanel.visible = false
	BonusSelectPanel.visible = true

func setgame():
	MainMenuPanel.visible = false
	SettingsPanel.visible = true

func resumegame():
	cancel()
	FPSC_Player.sessionPlayer.paused = false
	get_tree().paused = false
	FPSC_Player.sessionPlayer.pausemenu = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()

func cancel():
	MainMenuPanel.visible = true
	BonusSelectPanel.visible = false
	ChapterSelectPanel.visible = false
	SettingsPanel.visible = false
	var sfa = FileAccess.open("user://gameconfig.mconf",FileAccess.WRITE)
	var sinputmap = {}
	CustomBooleanSettings = {}
	for element in ToggleButtonsContainer.get_children():
		CustomBooleanSettings[element.name] = element.button_pressed
		FPSC_LevelManager.set(element.name,element.button_pressed)
	for i_name in InputMap.get_actions():
		sinputmap[i_name] = InputMap.action_get_events(i_name)
	sfa.store_var([sinputmap,FPSC_LevelManager.sensitivity,FPSC_LevelManager.fov,CustomBooleanSettings],true)
	sfa.close()

var bindVal = null

func startKeybindSetting(key:String):
	print("Start key binding for " + key)
	bindval[key].text = bindval[key].text.split(" - ")[0] + " - [Assigning...]"
	bindVal = bindval[key]
	pass

func callback_manager(id:int):
	FPSC_LevelManager.CMDLine("map " + FPSC_LevelManager.metadata.Chapters.keys()[id])

func callback_manager2(id:int):
	FPSC_LevelManager.CMDLine("map " + FPSC_LevelManager.metadata.BonusChapters.keys()[id])

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if bindVal != null:
			var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			var keystring = OS.get_keycode_string(keycode)
			if keystring == " ": keystring = "[SPACE]"
			bindVal.text = bindVal.text.split(" - ")[0] + " - " + keystring + " (Click to rebind)"
			InputMap.action_erase_events("p_" + bindVal.name)
			InputMap.action_add_event("p_" + bindVal.name,event)
			bindVal = null
	if event is InputEventMouseButton:
		if bindVal != null and not event.pressed:
			event.pressed = true
			var keystring = "[MOUSE" + str(event.button_index) + "]"
			bindVal.text = bindVal.text.split(" - ")[0] + " - " + keystring + " (Click to rebind)"
			InputMap.action_erase_events("p_" + bindVal.name)
			InputMap.action_add_event("p_" + bindVal.name,event)
			bindVal = null


func OnSensitivitySliderModified(_value_changed: bool) -> void:
	FPSC_LevelManager.sensitivity = MouseSensitivitySlider.value
	pass # Replace with function body.

func OnFOVSliderModified(_value_changed: bool) -> void:
	FPSC_LevelManager.fov = FOVSlider.value
	pass # Replace with function body.
