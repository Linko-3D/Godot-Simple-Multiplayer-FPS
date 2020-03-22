extends KinematicBody

puppet var puppet_transform

func _ready():
	set_network_master(1)

func _process(delta):
	if is_network_master():
		if get_tree().get_nodes_in_group("Player"):
			var player = get_tree().get_nodes_in_group("Player")[0]
			print(player.global_transform.origin)
			look_at(player.global_transform.origin, Vector3.UP)
		rset_unreliable("puppet_transform", transform)
	else:
		transform = puppet_transform
