extends FPSC_Weapon

func _on_pickup_radius_body_entered(body: Node3D) -> void:
	if body is FPSC_Player:
		FPSC_GivePlayerMyself(body)
		visible = false
