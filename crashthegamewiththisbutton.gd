@tool
extends Node3D

# Toggle this boolean to True in the Inspector to build collisions
@export var build_collisions: bool = false:
	set(value):
		if value:
			_generate_collisions(self)
			print("Collisions successfully built for all MeshInstances!")
		build_collisions = false

func _generate_collisions(current_node: Node):
	# Check if the current node is a MeshInstance3D and has a valid mesh
	if current_node is MeshInstance3D and current_node.mesh:
		# Create a StaticBody3D sibling
		var static_body = StaticBody3D.new()
		static_body.name = "StaticBody3D"
		current_node.add_child(static_body)
		static_body.owner = get_tree().edited_scene_root
		
		# Create the trimesh collision sibling under the static body
		var trimesh_shape = current_node.create_trimesh_collision()
		
		# Move the generated trimesh shape data under the StaticBody3D instead of the Mesh
		if trimesh_shape:
			current_node.remove_child(trimesh_shape)
			static_body.add_child(trimesh_shape)
			trimesh_shape.owner = get_tree().edited_scene_root

	# Recursively iterate over all children in the scene
	for child in current_node.get_children():
		_generate_collisions(child)
