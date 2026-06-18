@tool
extends Camera3D
class_name FPSC_FollowCamera
## Base class for cameras that follow the player. It's basically SkyboxCamera 
## but the default movement scale is 1 and CameraOrigin's rotation affects the outcome.

@export var CameraOrigin : Node3D # The exit portal (Destination)
@export var SelfOrigin : Node3D   # The entrance portal (Source)
@export var MovementScale : int = 1
@export var PortalTest := true

var canMove = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if CameraOrigin == null or SelfOrigin == null: 
		return # We literally CANNOT survive without our portal origins
		
	if canMove:
		var pc : Camera3D
		if not Engine.is_editor_hint():
			# Ensure sessionPlayer exists before fetching the node
			if FPSC_Player.sessionPlayer == null: return
			pc = FPSC_Player.sessionPlayer.get_node("Camera3D")
		else:
			pc = EditorInterface.get_editor_viewport_3d().get_camera_3d()
		
		if pc == null: return
		fov = pc.fov
		
		# 1. Calculate the relative rotation matrix between the entrance and exit.
		# We include a 180 flip along the Y-axis (UP) because portals face "out" of surfaces.
		var exit_facing_flip := Basis(Vector3.UP, PI)
		var portal_delta_basis := CameraOrigin.global_transform.basis * exit_facing_flip * SelfOrigin.global_transform.affine_inverse().basis
		
		# 2. Calculate the position difference relative to the entrance portal
		var player_camera_pos := pc.global_transform.origin
		var relative_pos := player_camera_pos - SelfOrigin.global_transform.origin
		
		# 3. Apply the rotation delta to the position offset and add to destination
		global_transform.origin = CameraOrigin.global_transform.origin + (portal_delta_basis * relative_pos)
		
		# 4. Map the player's camera rotation through the portal transform delta
		global_transform.basis = portal_delta_basis * pc.global_transform.basis


func ToggleMovement():
	canMove = not canMove
