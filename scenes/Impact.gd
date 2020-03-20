extends MeshInstance

func impact_sound(player):
	if player:
		$ImpactPlayerSound.play()
	else:
		$ImpactSound.play()
