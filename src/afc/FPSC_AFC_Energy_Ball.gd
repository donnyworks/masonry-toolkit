extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var health = 100.0 # Lifetime.

func FPSC_GetMPState():
	return []
	#return [position, rotation, velocity]

func FPSC_ApplyMPState(state):
	#position = state[0]
	pass
	#rotation = state[1]
	#velocity = state[2]

func _physics_process(delta: float) -> void:
	if health <= 0: queue_free(); return
	health -= delta*5.0 # Energy pellets last 20 seconds
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := (transform.basis * Vector3(0, 0, -1)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x = move_toward(velocity.y, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# 3. Check if the object we bumped into is a RigidBody
		# Use RigidBody2D for 2D projects
		#if not collider is RigidBody3D:
		# 1. Incoming forward direction
		if collider is RigidBody3D: 
			# Calculate the push direction (away from the player)
			var push_dir = -collision.get_normal()
			
			# Define how heavy/strong the push force should be
			var push_force = 2.0 
			
			# Apply an impulse to the RigidBody
			# For 2D: collider.apply_impulse(push_dir * push_force)
			collider.apply_impulse(push_dir * push_force, collision.get_position() - collider.global_position)

		var forward = -transform.basis.z # Or transform.basis.z depending on model forward axis

		# 2. Bounce vector
		var reflected_dir = forward.bounce(collision.get_normal())

		# 3. Orient transform to look along the new vector
		transform = transform.looking_at(global_position + reflected_dir, Vector3.UP)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is FPSC_Player:
		body.health = 0
	pass # Replace with function body.
