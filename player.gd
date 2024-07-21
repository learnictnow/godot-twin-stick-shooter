extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var last_direction = Vector3.FORWARD
var turret_last_direction = Vector3.FORWARD
@export var rotation_speed = 2

var mouse_enabled = true

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
		last_direction = direction
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	$Body.rotation.y = lerp_angle($Body.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)
	$CollisionShape3D.rotation.y = lerp_angle($CollisionShape3D.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)

	if !mouse_enabled:
		var turret_input_dir = Input.get_vector("turret_left", "turret_right", "turret_up", "turret_down")
		var turret_direction = (transform.basis * Vector3(turret_input_dir.x, 0, turret_input_dir.y)).normalized()
		if turret_direction:
			turret_last_direction = turret_direction
		$Turret.rotation.y = lerp_angle($Turret.rotation.y, atan2(-turret_last_direction.x, -turret_last_direction.z), delta * rotation_speed)
	move_and_slide()
	
func _process(delta):
	if mouse_enabled:
		look_at_cursor()

func _input(event):
	if Input.is_action_just_pressed("toggle_mouse"):
		mouse_enabled = !mouse_enabled

func look_at_cursor():
	var target_plane_mouse = Plane(Vector3(0,1,0), position.y)
	var ray_length = 1000
	var mouse_position = get_viewport().get_mouse_position()
	var from = $Camera3D.project_ray_origin(mouse_position)
	var to = from + $Camera3D.project_ray_normal(mouse_position) * ray_length
	var cursor_position_on_plane = target_plane_mouse.intersects_ray(from, to)
	
	$Turret.look_at(cursor_position_on_plane, Vector3.UP, 0)
