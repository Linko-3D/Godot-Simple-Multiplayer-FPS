extends KinematicBody

puppet var puppet_transform = transform
puppet var puppet_visibility = true
puppet var puppet_collision = false

var agro = 999
var target = null

var health = 100

func _ready():
	set_network_master(1)

func _process(delta):
	if is_network_master():
		if health <= 0:
			visible = false
			$CollisionShape.disabled = true
		
		if get_tree().get_nodes_in_group("Player"):
			var player = get_tree().get_nodes_in_group("Player")[0]
			
			look_at(player.global_transform.origin, Vector3.UP)
		rset_unreliable("puppet_transform", transform)
		rset_unreliable("puppet_visibility", visible)
		rset_unreliable("puppet_collision", $CollisionShape.disabled)
	else:
		transform = puppet_transform
		visible = puppet_visibility
		$CollisionShape.disabled = puppet_collision

remotesync func damaged(amount):
	health -= amount
