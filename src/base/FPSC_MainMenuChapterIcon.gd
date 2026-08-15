extends VBoxContainer
class_name FPSC_MainMenuChapterIcon

# wow

@export var button : TextureButton
@export var label : Label
var id = -1

signal callback(id:int)

func _ready():
	button.connect("pressed",prep_callback)

func prep_callback():
	callback.emit(id)
