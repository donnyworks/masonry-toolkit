extends Node3D
class_name FPSC_Weapon

# Base combat wepaon

var viewmodel = null
var PrimaryAmmoCount = 1
var SecondaryAmmoCount = 1
var OwnerPlayer : FPSC_Player = null

var CanBeEquipped = true

func _ready():
	if FPSC_Player.sessionPlayer != null: OwnerPlayer = FPSC_Player.sessionPlayer
	if CanBeEquipped:
		viewmodel = FPSC_LoadViewmodel()
		FPSC_Preload()
	else:
		queue_free()
		set_process(false)

# Realistically, you should only need to touch functions past this point

func FPSC_Preload(): pass

func FPSC_WeaponOnPickerHover():
	pass

func FPSC_CanWeaponBeSelected():
	return FPSC_CanPrimaryFire() or FPSC_CanSecondaryFire()

func FPSC_OnWeaponSelect(): # Called when the player selects us as their weapon
	OwnerPlayer.FPSC_SetupViewmodel(viewmodel) # We have to re-setup the viewmodel because it gets deleted on weapon swap

func FPSC_LoadViewmodel():
	return Node3D.new() # You'd respond with your viewmodel instead if we had one

func FPSC_GetPrimaryAmmoCount():
	return 1

func FPSC_GetSecondaryAmmoCount():
	return 1

func FPSC_CanPrimaryFire():
	return FPSC_GetPrimaryAmmoCount() > 0 # This is where you check for ammo and stuff

func FPSC_CanSecondaryFire():
	return FPSC_GetSecondaryAmmoCount() > 0

func FPSC_StartPrimaryFire():
	pass

func FPSC_StartSecondaryFire():
	pass

func FPSC_EndPrimaryFire():
	pass

func FPSC_EndSecondaryFire():
	pass

func FPSC_PrimaryFire():
	pass

func FPSC_SecondaryFire():
	pass

func FPSC_Reload():
	pass # If you were working with a gun, you'd do something like "if round(FPSC_GetPrimaryAmmoCount() / clipSize) > 0, reload"

func FPSC_GivePlayerMyself(player : FPSC_Player):
	OwnerPlayer = player
	player.currentWeapon = self ## TODO: Add proper inventory system, this is a horrific cheap hack!
	player.FPSC_SetupViewmodel(viewmodel)

# These functions are related to saving and loading

static func FPSC_IsSaveClass(classname): # RestoreFromSaveTable is only called if this is true
	return classname == "FPSC_BaseWeapon"

func FPSC_GetSaveTable():
	return {"WeaponClass":"FPSC_BaseWeapon","PrimaryAmmoCount":PrimaryAmmoCount,"SecondaryAmmoCount":SecondaryAmmoCount}

func FPSC_GetStateData():
	var data = {"position":position,"rotation":rotation,"scale":scale}
	data.merge(FPSC_GetSaveTable())
	return data

func FPSC_RestoreFromSaveTable(st):
	PrimaryAmmoCount = st.PrimaryAmmoCount
	SecondaryAmmoCount = st.SecondaryAmmoCount

func FPSC_GenerateFromDataTable(dt):
	if dt.WeaponClass == "FPSC_BaseWeapon":
		FPSC_RestoreFromSaveTable(dt)
		return self
	else:
		var object = ClassDB.instantiate(dt.WeaponClass) # BAD PRACTICE! Someone could inject a script class and END THE WORLD!!!
		object.FPSC_RestoreFromSaveTable(dt)
		return object

func FPSC_GetMPState():
	return FPSC_GetStateData()

func FPSC_ApplyMPState(state):
	position = state.position
	rotation = state.rotation
	scale = state.scale
	FPSC_RestoreFromSaveTable(state)
