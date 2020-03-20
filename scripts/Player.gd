extends KinematicBody

var movement = Vector3()

var speed = 10
var walk_speed = 10
var sprint_speed = 15

var jump_force = 6.5

var health = 100
var max_ammo = 20
var ammo = 20
var score = 0

var can_shoot = true

var bullet = "res://scenes/Bullet.tscn"
var impact = "res://scenes/Impact.tscn"

puppet var puppet_transform = null
puppet var puppet_camera_rotation = null
puppet var puppet_weapon_rotation = null

func _ready():
	if is_network_master():
		$Camera.current = true
		$Camera/HeadOrientation.visible = false
		$HUD.visible = true
		$Camera/RayCast.enabled = true
		$Camera/RayCast.add_exception(self)
		
func _physics_process(delta):
	if is_network_master():
		$HUD/Ammo.text = str(ammo)
		
		$HUD/Health.text = str(health)
		$HUD/Score.text = "Score: " + str(score)
		
		if health <= 0:
			rpc("respawn")
		
		if Input.is_action_pressed("sprint"):
			speed = sprint_speed
		else:
			speed = walk_speed
		
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
		rset_unreliable("puppet_weapon_rotation", $Camera/WeaponPosition.rotation)
		
	else:
		transform = puppet_transform
		$Camera.rotation = puppet_camera_rotation
		$Camera/WeaponPosition.rotation = puppet_weapon_rotation

func _input(event):
	if is_network_master():
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				rotation_degrees.y -= event.relative.x / 10
				$Camera.rotation_degrees.x -= event.relative.y / 10
				$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x, -90, 90)

func other_abilities():
	
	if $Camera/RayCast.is_colliding():
		$Camera/WeaponPosition.look_at($Camera/RayCast.get_collision_point(), Vector3.UP)
	else:
		$Camera/WeaponPosition.rotation = Vector3()
	
	
	if Input.is_action_just_pressed("shoot"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if can_shoot and ammo > 0:
				rpc("ammo")
				can_shoot = false
				$FireRate.start()
				rpc("shoot", $Camera/WeaponPosition/Weapon/BulletPosition.global_transform, $Camera/WeaponPosition/Weapon/BulletPosition.global_transform.basis.z)
				rpc("shoot_light")
				
				if $Camera/RayCast.is_colliding():
					var target = $Camera/RayCast.get_collider()
					
					rpc("impact", $Camera/RayCast.get_collision_point() )
					
					if target.has_method("damaged"):
						target.rpc("damaged")
						if target.health == 0:
							rpc("scored")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

remotesync func ammo():
	ammo -= 1

remotesync func impact(position):
	var impact_instance = load(impact).instance()
	impact_instance.global_transform.origin = position
	get_tree().get_root().get_node("Map").add_child(impact_instance)
	yield(get_tree().create_timer(2), "timeout")
	impact_instance.queue_free()

remotesync func shoot(emitter, direction):
	$Camera/ShootSound.play()
	
	var bullet_instance = load(bullet).instance()
	
	get_tree().get_root().get_node("Map").add_child(bullet_instance)
	bullet_instance.global_transform = emitter
	bullet_instance.linear_velocity = direction * - 500
	yield(get_tree().create_timer(2), "timeout")
	bullet_instance.queue_free()

remotesync func shoot_light():
	$Camera/WeaponPosition/Weapon/BulletPosition/ShootLight.visible = true
	yield(get_tree().create_timer(0.05), "timeout")
	$Camera/WeaponPosition/Weapon/BulletPosition/ShootLight.visible = false
	
remotesync func scored():
	score += 1

remotesync func respawn():
	health = 100
	global_transform = get_tree().get_root().find_node("Spawn", true, false). global_transform

remotesync func damaged():
	health -= 25


func _on_FireRate_timeout():
	can_shoot = true
