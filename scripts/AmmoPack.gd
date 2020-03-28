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

	rotate_y(-0.05)

	if picked:
		visible = false
		$CollisionShape.disabled = true
	else:
		visible = true
		$CollisionShape.disabled = false
	
func _on_AmmoPack_body_entered(body):
	if body.is_in_group("Player"):
		if body.ammo < body.max_ammo:
			rpc("refill_ammo", body)
			$Timer.start()

remotesync func refill_ammo(body):
	body.ammo = body.max_ammo
	picked = true

func _on_Timer_timeout():
	picked = false
