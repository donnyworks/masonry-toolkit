extends FPSC_Weapon
class_name FPSC_WeaponPortalgun

func FPSC_LoadViewmodel():
	return preload("res://viewmodel/vmdl_Portalgun.tscn").instantiate()

var current_portal1 = null
var current_portal2 = null
var portal_template = preload("res://instances/portal/PortalInstance.tscn")

func FPSC_Reload():
	if current_portal1 != null:
		current_portal1.queue_free()
	if current_portal2 != null:
		current_portal2.queue_free()
	current_portal1 = null
	current_portal2 = null
	pass

func Portalgun_CanFire():
	var base = OwnerPlayer.get_node("Camera3D/RayCast3D").is_colliding()
	if not base:
		return false
	if not OwnerPlayer.get_node("Camera3D/RayCast3D").get_collider().is_in_group("Non-Portalable"):
		return true
	return false

func FPSC_CanPrimaryFire(): return Portalgun_CanFire()

func FPSC_CanSecondaryFire(): return Portalgun_CanFire()

func get_euler_from_normal(normal: Vector3) -> Vector3:
	# 1. Use World UP as a reference. If looking straight up/down, use Forward.
	var up_reference = Vector3.UP if abs(normal.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
	
	# 2. Calculate correct perpendicular X and Z axes
	var right = normal.cross(up_reference).normalized()
	var forward = right.cross(normal).normalized()
	
	# 3. Build a fresh, clean Basis
	var basis = Basis(right, normal, forward)
	
	# 4. Extract the correct Euler angles
	return basis.get_euler()

func ModifyHelper(portal : FPSC_Portal, point, normal):
	if portal.marked_collider != null:
		portal.marked_collider.use_collision = true
	if portal.marked_other_collider != null:
		portal.marked_other_collider.use_collision = true
	portal.global_position = point
	
	# 1. Establish stable world sky reference
	var up_reference = Vector3.UP if abs(normal.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
	
	# 2. Calculate horizontal side vector perpendicular to the wall
	var calculated_z = normal.cross(up_reference).normalized()
	
	# 3. Calculate true vertical vector perpendicular to both
	var calculated_y = calculated_z.cross(normal).normalized()
	
	# 4. Map vectors directly to your X-oriented CSG mesh layout
	# X = Wall Normal, Y = Sky Up, Z = Side Horizon
	portal.global_transform.basis = Basis(normal, calculated_y, calculated_z)
	if normal.y == 1 or normal.y == -1:
		portal.rotation.y = OwnerPlayer.rotation.y - deg_to_rad(90)

func get_cam_raycast():
	return OwnerPlayer.get_node("Camera3D/RayCast3D")

var justFiredLeft = false
var justFiredRight = false

func FPSC_GetMPState():
	var data = [justFiredLeft,justFiredRight]
	justFiredLeft = false
	justFiredRight = false
	return data

func FPSC_ApplyMPState(state):
	if state[0]:
		FPSC_StartPrimaryFire()
	if state[1]:
		FPSC_StartSecondaryFire()

func FPSC_StartPrimaryFire():
	if FPSC_LevelManager.demo_data == {}: justFiredLeft = true
	var point = get_cam_raycast().get_collision_point()
	var normal = get_cam_raycast().get_collision_normal()
	if current_portal1 == null:
		current_portal1 = portal_template.duplicate().instantiate()
		get_tree().current_scene.add_child(current_portal1)
	ModifyHelper(current_portal1,point,normal)

func FPSC_StartSecondaryFire():
	if FPSC_LevelManager.demo_data == {}: justFiredRight = true
	var point = get_cam_raycast().get_collision_point()
	var normal = get_cam_raycast().get_collision_normal()
	if current_portal2 == null:
		current_portal2 = portal_template.duplicate().instantiate()
		get_tree().current_scene.add_child(current_portal2)
	ModifyHelper(current_portal2,point,normal)

func _on_pickup_radius_body_entered(body: Node3D) -> void:
	if body is FPSC_Player:
		FPSC_GivePlayerMyself(body)
		visible = false
	pass # Replace with function body.
