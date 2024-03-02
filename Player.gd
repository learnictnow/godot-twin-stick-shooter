extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var weapon_dir_prev = 0
var look_dir_prev = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if velocity != Vector3.ZERO:
		
		var lookdir = atan2(-velocity.x, -velocity.z)
		
			
		$Body.rotation.y = lerp_angle($Body.rotation.y, lookdir, 0.1)
		
		$UI/VBoxContainer/LabelRotation.text = str(rad_to_deg($Body.rotation.y))
		$UI/VBoxContainer/LabelRotation2.text = str(rad_to_deg(lookdir))
	
	
	var weapon_dir = Input.get_vector("weapon_left", "weapon_right", "weapon_up", "weapon_down")
	
	var lookdir = atan2(-weapon_dir.x, -weapon_dir.y)
	
	#if weapon_dir_prev - lookdir > 0:
	#	lookdir = -lookdir
	
	#$UI/VBoxContainer/InputDir.text = "Cur:  " + str(lookdir)
	#$UI/VBoxContainer/InputDirPrev.text = "Prev: " + str(weapon_dir_prev)
	##print("Cur:  " + str(lookdir) + " | Prev: " + str(weapon_dir_prev))
	#if lookdir - weapon_dir_prev > 0:
		#lookdir = -lookdir
	
	weapon_dir_prev = lookdir	
			
	$Weapon.rotation.y = lerp_angle($Weapon.rotation.y, lookdir, 0.1)


	var mouse_position = get_viewport().get_mouse_position()
	
	var ray_origin = Vector3()
	var ray_target = Vector3()
	
	ray_origin = $Camera3D.project_ray_origin(mouse_position)
	ray_target = ray_origin + $Camera3D.project_ray_origin(mouse_position) * 2000
	
	var space_state = get_world_3d().direct_space_state
	var intersection = space_state.intersect_ray(ray_origin)
	
	
