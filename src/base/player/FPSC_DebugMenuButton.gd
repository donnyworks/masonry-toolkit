extends Button
class_name FPSC_HUD_DebugOverlayButton

signal ButtonPressure(buttonLabel)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed",OnButtonPress)
	pass # Replace with function body.

func OnButtonPress():
	ButtonPressure.emit(text)
	pass
