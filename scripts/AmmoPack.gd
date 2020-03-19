extends Area

var picked = false
puppet var puppet_picked = false


func _ready():
	set_network_master(1)

func _process(delta):
	if is_network_master():
		rset("puppet_picked", picked)
	else:
		picked = puppet_picked
	
	if picked:
		visible = false
		$CollisionShape.disabled = true

func _on_AmmoPack_body_entered(body):
	if body.is_in_group("Player"):
		body.ammo = body.max_ammo
		picked = true
