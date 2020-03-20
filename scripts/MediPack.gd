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
	else:
		visible = true
		$CollisionShape.disabled = false 

func _on_MediPack_body_entered(body):
	if body.is_in_group("Player"):
		if body.health < 100:
			rpc("restore_health", body)
			$Timer.start()

remotesync func restore_health(body):
	body.health = 100
	picked = true

func _on_Timer_timeout():
	picked = false
