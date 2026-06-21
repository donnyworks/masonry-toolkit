extends FPSC_Trigger
class_name FPSC_TriggerDestroyPortals

func on_enter(body:Node3D):
	if body is FPSC_Player:
		if body.currentWeapon is FPSC_WeaponPortalgun:
			var cw : FPSC_WeaponPortalgun = body.currentWeapon
			if cw.current_portal1 != null:
				cw.current_portal1.queue_free()
				cw.current_portal1 = null
			if cw.current_portal2 != null:
				cw.current_portal2.queue_free()
				cw.current_portal2 = null
