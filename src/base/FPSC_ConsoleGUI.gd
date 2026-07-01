extends CanvasLayer

var stale_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta):
	if Input.is_action_just_pressed("showconsole"):
		if not visible:
			get_tree().paused = true
			if FPSC_Player.sessionPlayer != null:
				FPSC_Player.sessionPlayer.paused = true
			stale_mode = Input.mouse_mode
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			get_tree().paused = false
			if FPSC_Player.sessionPlayer != null:
				FPSC_Player.sessionPlayer.paused = false
			Input.set_mouse_mode(stale_mode)
		visible = not visible
		if visible:
			# Block clicks from hitting the game, focus the text input
			$console_rend.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			# Let clicks pass through to the game, release focus
			$console_rend.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready():
	FPSC_LevelManager.console = console

func console(text):
	$console_rend/RichTextLabel.text += text + "\n"

func _on_line_edit_text_submitted(new_text: String) -> void:
	$console_rend/LineEdit.text = ""
	FPSC_LevelManager.CMDLine(new_text)
	pass # Replace with function body.
