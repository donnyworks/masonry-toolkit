@tool
extends SubViewport
class_name FPSC_ViewTexture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var ws = get_window().size
	if Engine.is_editor_hint():
		ws = EditorInterface.get_editor_viewport_3d().size
	if size != ws:
		size = ws
	pass
