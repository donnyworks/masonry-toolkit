extends Control
class_name FPSC_MainMenuDialogManager

@export var ChapterSelectBoxContainer : Control
@export var BonusSelectBoxContainer : Control
@export var ChapterSelectButtonTemplate : FPSC_MainMenuChapterIcon
@export var MainMenuPanel : Control
@export var ChapterSelectPanel : Control
@export var BonusSelectPanel : Control
@export var NewGameButton : BaseButton
@export var BonusGameButton : BaseButton
@export var SettingsButton : BaseButton
@export var QuitGameButton : BaseButton
@export var ChapterSelectAbortButton : BaseButton
@export var BonusSelectAbortButton : BaseButton
@export var GameNameLabel : Label
@export var GameVersionLabel : Label

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
	QuitGameButton.connect("pressed",get_tree().quit)
	ChapterSelectAbortButton.connect("pressed",cancel)
	BonusSelectAbortButton.connect("pressed",cancel)
	GameNameLabel.text = FPSC_LevelManager.metadata.GameName
	GameVersionLabel.text = FPSC_LevelManager.metadata.Version

func newgame():
	MainMenuPanel.visible = false
	ChapterSelectPanel.visible = true

func bonegame():
	MainMenuPanel.visible = false
	BonusSelectPanel.visible = true

func cancel():
	MainMenuPanel.visible = true
	BonusSelectPanel.visible = false
	ChapterSelectPanel.visible = false
	

func callback_manager(id:int):
	FPSC_LevelManager.CMDLine("map " + FPSC_LevelManager.metadata.Chapters.keys()[id])

func callback_manager2(id:int):
	FPSC_LevelManager.CMDLine("map " + FPSC_LevelManager.metadata.BonusChapters.keys()[id])
