extends CSGBox3D
class_name FPSC_Portal
## Just because this is a class you can choose doesn't mean you should.
## Please do not select this from the editor, it relies on its own FPSC_FollowCamera to work.

@export var linked : bool = false
@export var other_portal : FPSC_Portal = null
@export var portal_pair_linkage_id : int = 0
@export var portal_color : bool = true

func ClosePortal():
	linked = false
	other_portal = null
	visible = false

func NotifyOtherPortalDestruction():
	queue_free()

func NotifyLinkage():
	linked = true
	portal_color = not other_portal.portal_color
	$Portal1Texture/FPSC_FollowCamera.CameraOrigin = other_portal

func _process(delta):
	if not linked:
		$A1.visible = true
		$A2.visible = true
		for node in get_tree().get_nodes_in_group("Portals"):
			if node is FPSC_Portal:
				if node.portal_pair_linkage_id == portal_pair_linkage_id and node != self and not node.linked:
					node.other_portal = self
					portal_color = not node.portal_color
					linked = true
					other_portal = node
					$Portal1Texture/FPSC_FollowCamera.CameraOrigin = node
					node.linked = true
					node.NotifyLinkage()
	else:
		$A1.visible = false
		$A2.visible = false
		if $Portal1Texture/FPSC_FollowCamera.get_cull_mask_value(3):
			$Portal1Texture/FPSC_FollowCamera.set_cull_mask_value(3,false)
		if $RayCast3D.get_collider() is CSGShape3D:
			$RayCast3D.get_collider().set_layer_mask_value(1,false)
			$RayCast3D.get_collider().set_layer_mask_value(3,true)

var marked_collider : CSGShape3D = null

var marked_other_collider : CSGShape3D = null
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not linked: return
	if body is FPSC_Player or body is RigidBody3D:
		if $RayCast3D.is_colliding():
			if $RayCast3D.get_collider() is CSGShape3D:
				$RayCast3D.get_collider().use_collision = false
				marked_collider = $RayCast3D.get_collider()
				var mok_temp = other_portal.get_node("RayCast3D").get_collider() if other_portal.get_node("RayCast3D").is_colliding() else marked_other_collider
				marked_other_collider = mok_temp if mok_temp is CSGShape3D else marked_other_collider
				if marked_other_collider != null: marked_other_collider.use_collision = false
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not linked: return
	if body is FPSC_Player or body is RigidBody3D:
		if $RayCast3D.is_colliding():
			if $RayCast3D.get_collider() is CSGShape3D:
				$RayCast3D.get_collider().use_collision = true
				var mok_temp = other_portal.get_node("RayCast3D").get_collider() if other_portal.get_node("RayCast3D").is_colliding() else marked_other_collider
				marked_other_collider = mok_temp if mok_temp is CSGShape3D else marked_other_collider
				if marked_other_collider != null: marked_other_collider.use_collision = true
			elif marked_collider != null:
				marked_collider.use_collision = true
				if marked_other_collider != null: 
					marked_other_collider.use_collision = true
		else:
			if marked_collider != null:
				marked_collider.use_collision = true
			if marked_other_collider != null: 
				marked_other_collider.use_collision = true
	pass # Replace with function body.


func _on_passthrough_area_body_entered(body: Node3D) -> void:
	if body is FPSC_Player or body is RigidBody3D:
		if $RayCast3D.is_colliding():
			if $RayCast3D.get_collider() is CSGShape3D:
				$RayCast3D.get_collider().use_collision = false
				var mok_temp = other_portal.get_node("RayCast3D").get_collider() if other_portal.get_node("RayCast3D").is_colliding() else marked_other_collider
				marked_other_collider = mok_temp if mok_temp is CSGShape3D else marked_other_collider
				if marked_other_collider != null: marked_other_collider.use_collision = false
			elif marked_collider != null:
				marked_collider.use_collision = false
				if marked_other_collider != null: marked_other_collider.use_collision = false
		else:
			if marked_collider != null:
				marked_collider.use_collision = false
			if marked_other_collider != null: 
				marked_other_collider.use_collision = false
		var pc_t = body.global_transform

		# 2. Convert player camera to Source Portal's LOCAL space
		# This tells us where the camera is relative to the entrance
		var local_to_source = self.global_transform.affine_inverse() * pc_t

		# 3. Portals are "mirrors" where you go in the front and out the front.
		# We rotate the local position/basis by 180 degrees around the Up axis
		# to point the camera OUT of the destination portal.
		var flip_180 = Basis.IDENTITY.rotated(Vector3.UP, PI)
		var flipped_local = Transform3D(flip_180, Vector3.ZERO) * local_to_source

		# 4. Map that flipped local transform to the Destination Portal's GLOBAL space
		var final_transform = other_portal.global_transform * flipped_local

		body.global_transform = final_transform
		if body is FPSC_Player: 
			body.get_node("Camera3D").rotation.x += body.global_rotation.z
		if body is FPSC_Player: body.global_rotation.x = 0
		if body is FPSC_Player: body.global_rotation.z = 0
		var exit_flip = Basis(Vector3.UP, PI)
		var portal_delta_basis = other_portal.global_transform.basis * exit_flip * global_transform.basis.inverse()

		# 2. Grab the player's current velocity
		var old_velocity = body.velocity

		# 3. Rotate the velocity vector
		# This maps the velocity from the entrance's orientation to the exit's orientation
		var new_velocity = portal_delta_basis * old_velocity

		# 4. Apply it back to the player
		body.velocity = new_velocity
	pass # Replace with function body.


func _on_passthrough_area_body_exited(body: Node3D) -> void:
	if body is FPSC_Player or body is RigidBody3D:
		if $RayCast3D.is_colliding():
			if $RayCast3D.get_collider() is CSGShape3D:
				$RayCast3D.get_collider().use_collision = true
				var mok_temp = other_portal.get_node("RayCast3D").get_collider() if other_portal.get_node("RayCast3D").is_colliding() else marked_other_collider
				marked_other_collider = mok_temp if mok_temp is CSGShape3D else marked_other_collider
				#if marked_other_collider != null: marked_other_collider.use_collision = true
			elif marked_collider != null:
				marked_collider.use_collision = true
				#if marked_other_collider != null: marked_other_collider.use_collision = true
		else:
			if marked_collider != null:
				marked_collider.use_collision = true
				#wif marked_other_collider != null: marked_other_collider.use_collision = true
	pass # Replace with function body.
