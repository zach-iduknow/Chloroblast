extends KinematicBody

#basic player movement variables
export var speed := 7.0
export var gravity := 9.8
export var jump_force := 5.0

#player movement vectors(movment is the final vector used for move_and_slide())
var movement = Vector3()
#keeps track of player direction
var direction = Vector3()
#keeps track of how fast player is moving
var velocity = Vector3()
#keeps track of how fast the player is falling
var gravity_vector = Vector3()

#control feel
export var mouse_sensitivity := 0.2
#acceleration to max speed when player is moving
export var default_acceleration = 7
export var air_acceleration = 1
onready var acceleration = default_acceleration
#used for standing on slopes
var snap

#player components
onready var head = $Head
onready var camera = $Head/Camera

func _ready():
	#locks mouse to center of the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89.0), deg2rad(89.0))

	
func _physics_process(delta):
	#resetting the direction vector every frame
	direction = Vector3.ZERO
	#gets whatever current y rotation we have from the basis matrix
	var h_rotation = global_transform.basis.get_euler().y
	var forward_movement = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var right_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#sets the direction vector with the forward and right inputs, rotated by the current y rotation
	direction = Vector3(right_movement, 0 ,forward_movement).rotated(Vector3.UP,h_rotation).normalized()
	
	if is_on_floor():
		#makes center of gravity perpendicular to the floor's facing direction
		snap = -get_floor_normal()
		#reseting the acceleration gained from falling
		gravity_vector = Vector3.ZERO
	else:
		#only one direction to stick to
		snap = Vector3.DOWN
		#adding the acceleration from gravity
		gravity_vector += Vector3.DOWN * gravity * delta
	
	#I can eventually add a variable for double jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vector = Vector3.UP * jump_force
	
	#makes for smooth movement by interpolating from whatever the current direction is times speed by delta
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	movement = velocity + gravity_vector
	
	move_and_slide_with_snap(movement,snap,Vector3.UP)
