extends KinematicBody

#tutorial said this code is outdated, use this instead: https://github.com/GarbajYT/godot_updated_fps_controller/blob/main/FPS_controller_3.3/FPS.gd

var mouse_sensitivity = 0.03

var speed = 10
#vertical acceleration
var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump_force = 10
var full_contact = false

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vector = Vector3()

onready var head = $Head
onready var ground_check = $Ground_Check

func _ready():
	#locks the cursor to the center of the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#triggers whenever an input is done and an objbect consumes it
#Docs says _unhandled_input() might be better since GUI gets to see it first
#I think we do this to pureley capture mouse movement...like Input.GetMouseAxis in unity
func _input(event):
	if event is InputEventMouseMotion:
		#turns horizontal mouse movement to horizontal character rotation
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		#turns vertically based on mouse movement
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		#clams vertical rotation -89 and 89
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _physics_process(delta):
	direction = Vector3()
	
	if ground_check.is_colliding():
		full_contact = true
	else:
		full_contact = false
	
	if !is_on_floor():
		gravity_vector += Vector3.DOWN * gravity * delta
		#ensures acceleration is conserved during jumping
		h_acceleration = air_acceleration
		#raycasts only detect what's at the tip of it
		#so if the player is on the floor but the raycast has detected something, the player falls
		#if the raycast detects nothing but they player is on the floor it collides
	elif is_on_floor() and full_contact:
		#ensures that player sticks to floor when they're down
		#ensures gravity is perpendicular to the floor, for slopes//solves issues with godot character controllers
		gravity_vector = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		#resets the gravity if the raycast is no longer colliding
		#stops the player form slamming in to the ground
		gravity_vector = -get_floor_normal()
		h_acceleration = normal_acceleration
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vector = Vector3.UP * jump_force
	
	if Input.is_action_pressed("move_forward"):
		#it just adds 1 in the axis we deicde
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	elif Input.is_action_pressed("move_left"):
		direction += transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction -= transform.basis.x
	
	#prevents accelerated movement while moving diagonally
	direction = direction.normalized()
	#set h_velocity to be the speed of the player by the rate of acceleration times fps
	#this smoothing is optional, if I was to remove it, replace movement with direction * speed in move_and_slide
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vector.z
	movement.x = h_velocity.x + gravity_vector.x
	movement.y = gravity_vector.y
	
	move_and_slide(movement, Vector3.UP)
	
	
