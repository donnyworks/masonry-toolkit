@tool
extends Camera3D
class_name FPSC_SkyboxCamera

static var CurrentCamera : FPSC_SkyboxCamera = self
@export var CameraOrigin : Node3D
@export var MovementScale : int = 16
@export var Offset : Vector3 = Vector3.ZERO

func _ready():
	CurrentCamera = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if CameraOrigin == null: return # We literally CANNOt survive without CameraOrigin
	if (not Engine.is_editor_hint()) and get_tree().root.get_camera_3d() == null: return
	#if FPSC_Player.sessionPlayer == null and not Engine.is_editor_hint(): return # Added because sv_listen can be false/0 now
	if canMove:
		if not Engine.is_editor_hint():
			rotation = get_tree().root.get_camera_3d().global_rotation
			var modpos = get_tree().root.get_camera_3d().global_position * Vector3(1,1,1)
			position = CameraOrigin.global_position + modpos/MovementScale + Offset
			fov = get_tree().root.get_camera_3d().fov
		else:
			var pc = Engine.get_singleton("EditorInterface").get_editor_viewport_3d().get_camera_3d()
			rotation = pc.global_rotation
			var modpos = pc.global_position * Vector3(1,1,1)
			position = CameraOrigin.global_position + modpos/MovementScale + Offset
			fov = pc.fov
	pass

var canMove = true

func ToggleMovement():
	canMove = not canMove
