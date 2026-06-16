extends Node3D

const prefix_none = "nofired"
const prefix_blue = "fired"
const prefix_red = "firedred"
const prefix_both = "firedboth"

var textures = {
	"none cant fire":preload("res://textures/hud/" + prefix_none + "_nosurface.png"),
	"none can fire":preload("res://textures/hud/" + prefix_none + "_surface.png"),
	"blue cant fire":preload("res://textures/hud/" + prefix_blue + "_nosurface.png"),
	"blue can fire":preload("res://textures/hud/" + prefix_blue + "_surface.png"),
	"red cant fire":preload("res://textures/hud/" + prefix_red + "_nosurface.png"),
	"red can fire":preload("res://textures/hud/" + prefix_red + "_surface.png"),
	"both cant fire":preload("res://textures/hud/" + prefix_both + "_nosurface.png"),
	"both can fire":preload("res://textures/hud/" + prefix_both + "_surface.png"),
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if FPSC_Player.sessionPlayer.currentWeapon is FPSC_WeaponPortalgun:
		var cw : FPSC_WeaponPortalgun = FPSC_Player.sessionPlayer.currentWeapon
		if cw.FPSC_CanPrimaryFire():
			if cw.current_portal1 != null and cw.current_portal2 != null:
				$TextureRect.texture = textures["both can fire"]
			elif cw.current_portal2 == null:
				$TextureRect.texture = textures["blue can fire"]
			elif cw.current_portal1 == null:
				$TextureRect.texture = textures["red can fire"]
			else:
				$TextureRect.texture = textures["none can fire"]
		else:
			if cw.current_portal1 != null and cw.current_portal2 != null:
				$TextureRect.texture = textures["both cant fire"]
			elif cw.current_portal2 == null:
				$TextureRect.texture = textures["blue cant fire"]
			elif cw.current_portal1 == null:
				$TextureRect.texture = textures["red cant fire"]
			else:
				$TextureRect.texture = textures["none cant fire"]
	pass
