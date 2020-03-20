extends Area

var picked = false

func _ready():
	set_network_master(1)

func _process(delta):
	if is_network_master():
		pass



func _on_MediPack_body_entered(body):
	if body.is_in_group("Player"):
		body.health = 120
