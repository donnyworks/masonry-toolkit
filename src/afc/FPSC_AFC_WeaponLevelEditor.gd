extends FPSC_Weapon
class_name FPSC_AFC_WeaponLevelEditor

# Generic test weapon to demo.

enum EditorMode {
	EDIT_MODE_NOPORTALS = 0,
	EDIT_MODE_PORTALS = 1
}

func FPSC_LoadViewmodel():
	var vm = preload("res://viewmodel/vmdl_testWeapon.tscn").instantiate()
	return vm

func _process(delta: float) -> void:
	if OwnerPlayer == null: return
	var base = OwnerPlayer.get_node("Camera3D/RayCast3D").is_colliding()
	if base:
		var col : Node3D = OwnerPlayer.get_node("Camera3D/RayCast3D").get_collider()
		var cn : Vector3 = OwnerPlayer.get_node("Camera3D/RayCast3D").get_collision_normal()
		var cp : Vector3 = OwnerPlayer.get_node("Camera3D/RayCast3D").get_collision_point()
		if cn == Vector3.UP:
			$floorAndCeilingPicker.global_position = round(cp/3)*3
			$floorAndCeilingPicker.global_position.y = cp.y
			$floorAndCeilingPicker.global_rotation_degrees = Vector3(-90,0,0)
			$floorAndCeilingPicker.visible = true

func FPSC_Reload():
	viewmodel.get_node("AnimationPlayer").play("reload")

func FPSC_StartPrimaryFire():
	viewmodel.get_node("AnimationPlayer").play("start_primary_fire")
	await viewmodel.get_node("AnimationPlayer").animation_finished


func _on_pickup_radius_body_entered(body: Node3D) -> void:
	if body is FPSC_Player:
		FPSC_GivePlayerMyself(body)
		$worldmodel.visible = false
