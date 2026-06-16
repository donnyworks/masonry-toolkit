@tool
extends Camera3D
class_name FPSC_FollowCamera
## Base class for cameras that follow the player. It's basically SkyboxCamera but the default movement scale is 1 and CameraOrigin's rotation affects the outcome

@export var CameraOrigin : Node3D
@export var SelfOrigin : Node3D # The portal the player is physically looking into
@export var MovementScale : int = 1
@export var PortalTest := true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if CameraOrigin == null or SelfOrigin == null: return # We literally CANNOt survive without CameraOrigin
	if canMove:
		var pc : Camera3D
		if not Engine.is_editor_hint():
			pc = FPSC_Player.sessionPlayer.get_node("Camera3D")
		else:
			pc = EditorInterface.get_editor_viewport_3d().get_camera_3d()
		fov = pc.fov
		# 1. Get the player's camera global transform
		var pc_t = pc.global_transform

		# 2. Convert player camera to Source Portal's LOCAL space
		# This tells us where the camera is relative to the entrance
		var local_to_source = SelfOrigin.global_transform.affine_inverse() * pc_t

		# 3. Portals are "mirrors" where you go in the front and out the front.
		# We rotate the local position/basis by 180 degrees around the Up axis
		# to point the camera OUT of the destination portal.
		var flip_180 = Basis.IDENTITY.rotated(Vector3.UP, PI)
		var flipped_local = Transform3D(flip_180, Vector3.ZERO) * local_to_source

		# 4. Map that flipped local transform to the Destination Portal's GLOBAL space
		var final_transform = CameraOrigin.global_transform * flipped_local

		global_transform = final_transform
		
var canMove = true

func ToggleMovement():
	canMove = not canMove
