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
	if body is CharacterBody3D or body is RigidBody3D:
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
	if body is CharacterBody3D or body is RigidBody3D:
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

# Add this variable at the top of your FPSC_Portal script
var bodies_to_ignore: Array[Node3D] = []

func _on_passthrough_area_body_entered(body: Node3D) -> void:
	if not linked: return
	
	# If this body was just sent here from the other portal, ignore it!
	if body in bodies_to_ignore:
		return

	if body is CharacterBody3D or body is RigidBody3D:
		# --- COLLISION MANIPULATION ---
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

		# --- TRANSLATION MATH ---
		var exit_facing_flip := Basis(Vector3.UP, PI)
		var portal_delta_basis := other_portal.global_transform.basis * exit_facing_flip * global_transform.affine_inverse().basis
		portal_delta_basis = portal_delta_basis.orthonormalized()

		var entity_pos := body.global_transform.origin
		var relative_pos := entity_pos - global_transform.origin
		
		# Keep a modest safety push out of the wall/floor surface
		var exit_forward := -other_portal.global_transform.basis.z.normalized()
		var safety_push := exit_forward * 0.05 # Increased this because we weren't clipping 
		print(exit_forward)
		if exit_forward.z > 0.25:
			safety_push = Vector3(safety_push.x,-safety_push.z,safety_push.y)*10.0
		print(safety_push)
		
		var final_position := other_portal.global_transform.origin + (portal_delta_basis * relative_pos) + safety_push

		# Tell the destination portal to ignore this body when it arrives
		other_portal.bodies_to_ignore.append(body)
		# Apply complete transform
		body.global_transform.origin = final_position
		body.global_transform.basis = portal_delta_basis * body.global_transform.basis

		# Rotate velocity using your clean inline dynamic statement
		var body_velocity : Vector3 = body.velocity if "velocity" in body else body.linear_velocity
		var rotated_velocity = portal_delta_basis * body_velocity
		
		if "velocity" in body:
			body.velocity = rotated_velocity
		else:
			body.linear_velocity = rotated_velocity
		
		if body is CharacterBody3D:
			body.move_and_slide()
		if body is FPSC_Player: body.global_rotation.x = 0
		if body is FPSC_Player: body.global_rotation.z = 0


# Clean up the array when they leave the destination portal
func _on_passthrough_area_body_exited(body: Node3D) -> void:
	if body in bodies_to_ignore:
		bodies_to_ignore.erase(body)
		return # Skip the rest of your collision resetting logic for this frame if needed

	# --- YOUR EXISTING COLLISION RESETTING LOGIC ---
	if body is CharacterBody3D or body is RigidBody3D:
		if $RayCast3D.is_colliding():
			if $RayCast3D.get_collider() is CSGShape3D:
				$RayCast3D.get_collider().use_collision = true
				var mok_temp = other_portal.get_node("RayCast3D").get_collider() if other_portal.get_node("RayCast3D").is_colliding() else marked_other_collider
				marked_other_collider = mok_temp if mok_temp is CSGShape3D else marked_other_collider
			elif marked_collider != null:
				marked_collider.use_collision = true
		else:
			if marked_collider != null:
				marked_collider.use_collision = true
			if marked_other_collider != null: 
				marked_other_collider.use_collision = true
