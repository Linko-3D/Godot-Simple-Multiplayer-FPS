extends KinematicBody

func _physics_process(delta):
	var group = get_tree().get_nodes_in_group("Player")
	
	if group.size() == 0:
		return
		
	var nearest = get_nearest(group)
	look_at(nearest.global_transform.origin, Vector3.UP)
	
	var vector = nearest.global_transform.origin - global_transform.origin
	vector = vector.normalized()
	move_and_collide(vector * 100 * delta)

func get_nearest(group):
	var nearest = group[0]

	for target in group:
		var target_distance = global_transform.origin.distance_to(target.global_transform.origin)
		var nearest_distance = global_transform.origin.distance_to(nearest.global_transform.origin)

		if target_distance < nearest_distance:
			nearest = target

	return nearest

