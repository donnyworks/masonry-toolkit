extends FPSC_Weapon
class_name FPSC_WeaponSrcbox

## Why aren't we just deleting SRCBOX? It's a shell, at this point. [Donovan 06/10/26]

# Generic test weapon to demo.

var FireStartDone = false

var wpn_is_instance = true

#var mat_std = preload("res://srcbox_default.tres")
#var mat_hvr = preload("res://srcbox_hover.tres")
#var mat_slc = preload("res://srcbox_selecetd.tres")

var isTouching = false

func FPSC_WeaponOnPickerHover(): # Called every frame when the picker is on the object
	#if $CSGBox3D.material != mat_hvr and not isTouching:
	#	$CSGBox3D.material = mat_hvr
	pass

func FPSC_Preload():
	wpn_is_instance = len(get_children()) > 1
	if wpn_is_instance: $Area3D.connect("body_entered",player_give_weapon)

#func FPSC_LoadViewmodel():
	#var vm = preload("res://viewmodel/srcfall.tscn").instantiate()
	#return vm

#func _process(delta: float) -> void:
	#if wpn_is_instance: $CSGBox3D.material = mat_std
	#if wpn_is_instance: $CSGBox3D.rotation_degrees.y += delta*50.0

func player_give_weapon(body):
	if body is FPSC_Player:
		isTouching = true
		#$CSGBox3D.material = mat_slc
		await RenderingServer.frame_post_draw
		body.currentWeapon = self
		FPSC_Player.sessionPlayer.FPSC_SetupViewmodel(viewmodel)
		body.set_script(load("res://src/sourcebox/ViewlookStub.gd"))
		visible = false


func FPSC_Reload():
	pass

func FPSC_StartPrimaryFire():
	pass

func FPSC_PrimaryFire():
	pass

func FPSC_EndPrimaryFire():
	pass
