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

func FPSC_CanPrimaryFire():
	return OwnerPlayer.get_node("Camera3D/RayCast3D").is_colliding()

func FPSC_CanSecondaryFire():
	return OwnerPlayer.get_node("Camera3D/RayCast3D").is_colliding()

func ModifyHelper(portal,point,normal):
	print("ModifyHelper: Normal is ",normal)
	var prepNormal = Vector3(0,normal.z*-90,normal.y*90)
	if normal.y < 0.0:
		prepNormal.y += normal.y*-180
	print("ModifyHelper: Calculated normal is ",prepNormal)
	portal.global_position = point
	portal.global_rotation_degrees = prepNormal

func get_cam_raycast():
	return OwnerPlayer.get_node("Camera3D/RayCast3D")

func FPSC_StartPrimaryFire():
	var point = get_cam_raycast().get_collision_point()
	var normal = get_cam_raycast().get_collision_normal()
	if current_portal1 == null:
		current_portal1 = portal_template.duplicate().instantiate()
		get_tree().current_scene.add_child(current_portal1)
	ModifyHelper(current_portal1,point,normal)

func FPSC_StartSecondaryFire():
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
