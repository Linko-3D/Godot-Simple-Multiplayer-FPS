extends KinematicBody

var movement = Vector3()
var speed = 10
var jump_force = 6.5

var health = 100
var score = 0

var can_shoot = true

puppet var puppet_transform = null
puppet var puppet_camera_rotation = null

func _ready():
	if is_network_master():
		$Camera.current = true
		$Camera/HeadOrientation.visible = false
		$HUD.visible = true
		$Camera/RayCast.enabled = true
		$Camera/RayCast.add_exception(self)

func _physics_process(delta):
	if is_network_master():
		
		$HUD/Health.text = str(health)
		$HUD/Score.text = "Score: " + str(score)
		
		if health <= 0:
			rpc("respawn")
		
		
		var direction_2D = Vector2()
		direction_2D.y = Input.get_action_strength("backward") - Input.get_action_strength("forward")
		direction_2D.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction_2D = direction_2D.normalized()
		
		movement.z = direction_2D.y * speed
		movement.x = direction_2D.x * speed
		movement.y -= 9.8 * delta
		
		movement = movement.rotated(Vector3.UP, rotation.y)
		
		if is_on_floor():
			if Input.is_action_just_pressed("ui_accept"):
				movement.y = jump_force
		
		movement = move_and_slide(movement, Vector3.UP)
	
		other_abilities()
		
		rset_unreliable("puppet_transform", transform)
		rset_unreliable("puppet_camera_rotation", $Camera.rotation)
	else:
		transform = puppet_transform
		$Camera.rotation = puppet_camera_rotation

func _input(event):
	if is_network_master():
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				rotation_degrees.y -= event.relative.x / 10
				$Camera.rotation_degrees.x -= event.relative.y / 10
				$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x, -90, 90)

func other_abilities():
	if Input.is_action_just_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if can_shoot:
			can_shoot = false
			$FireRate.start()
			rpc("shoot_sound")
			
			if $Camera/RayCast.is_colliding():
				var target = $Camera/RayCast.get_collider()
				
				if target.has_method("damaged"):
					target.rpc("damaged")
					if target.health == 0:
						rpc("scored")

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

remotesync func shoot_sound():
	$Camera/ShootSound.play()

remotesync func scored():
	score += 1

remotesync func respawn():
	health = 100
	global_transform = get_tree().get_root().find_node("Spawn", true, false). global_transform

remotesync func damaged():
	health -= 25


func _on_FireRate_timeout():
	can_shoot = true
