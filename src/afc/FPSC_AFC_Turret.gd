extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_found = false
	$ShapeCast3D.force_shapecast_update()
	for i in range($ShapeCast3D.get_collision_count()):
		var c = $ShapeCast3D.get_collider(i)
		#print(c.get_class())
		if c.has_method("FPSC_DealDamageTurret"):
			player_found = true
			if $TurretMoveJoint.rotation_degrees == Vector3.ZERO:
				var t = create_tween()
				t.tween_property($TurretMoveJoint,"rotation_degrees",Vector3(-90,0,0),1)
			if $TurretMoveJoint.rotation_degrees == Vector3(-90,0,0):
				$TurretMoveJoint/Sprite3D.visible = true
				$TurretMoveJoint/Sprite3D2.visible = true
				c.FPSC_DealDamageTurret()
				$AudioStreamPlayer3D.play()
	if not player_found and $TurretMoveJoint.rotation_degrees == Vector3(-90,0,0):
		var t = create_tween()
		t.tween_property($TurretMoveJoint,"rotation_degrees",Vector3(0,0,0),1)
		$TurretMoveJoint/Sprite3D.visible = false
		$TurretMoveJoint/Sprite3D2.visible = false
