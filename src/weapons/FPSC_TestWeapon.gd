extends FPSC_Weapon
class_name FPSC_TestWeapon

# Generic test weapon to demo.

func _init():
	if not FPSC_BuildFeatures.BuildFeatures.FEATURE_TESTWPN:
		CanBeEquipped = false

var FireStartDone = false

var l : OmniLight3D = null

var cached_stateful = "RESET"

func FPSC_Preload():
	if OwnerPlayer == null and FPSC_Player.sessionPlayer == null:
		return # Yeah no.
	OwnerPlayer.FPSC_SetupViewmodel(viewmodel)

func FPSC_LoadViewmodel():
	var vm = preload("res://viewmodel/vmdl_testWeapon.tscn").instantiate()
	l = vm.get_node("Sprite3D/OmniLight3D").duplicate()
	get_tree().current_scene.add_child(l)
	l.visible = false
	return vm

func _process(delta: float) -> void:
	if OwnerPlayer == null: return
	l.global_position = OwnerPlayer.get_node("Camera3D").global_position + viewmodel.get_node("Sprite3D/OmniLight3D").position

func FPSC_Reload():
	viewmodel.get_node("AnimationPlayer").play("reload")

func FPSC_StartPrimaryFire():
	viewmodel.get_node("AnimationPlayer").play("start_primary_fire")
	await viewmodel.get_node("AnimationPlayer").animation_finished
	FireStartDone = true

func FPSC_PrimaryFire():
	if FireStartDone and not viewmodel.get_node("AnimationPlayer").current_animation == "primary_fire":
		l.visible = true
		viewmodel.get_node("AnimationPlayer").play("fire")

func FPSC_EndPrimaryFire():
	FireStartDone = false
	l.visible = false
	viewmodel.get_node("AnimationPlayer").play_backwards("start_primary_fire")
	await viewmodel.get_node("AnimationPlayer").animation_finished
	viewmodel.get_node("AnimationPlayer").play("RESET")

func FPSC_GetSaveTable():
	return {"WeaponClass":"FPSC_TestWeapon","AnimState":viewmodel.get_node("AnimationPlayer").current_animation if not FPSC_GameState.isServer else cached_stateful}

func FPSC_RestoreFromSaveTable(st):
	if viewmodel.get_node("AnimationPlayer").current_animation != st.AnimState:
		viewmodel.get_node("AnimationPlayer").play(st.AnimState)
