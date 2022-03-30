extends KinematicBody

#basic player movement variables
export var speed := 7.0
export var gravity := 9.8
#increase fall speed
export var gravity_multi := 2.0
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
#slower acceleration means the play comes to a stop slower(good for in air travel)
export var air_acceleration = 1
onready var acceleration = default_acceleration
#used for standing on slopes
var snap

#maw - consuming level props and enemies
#checks to see if your're looking at an enemy
var target_enemy

#Player Stats
var max_hp := 100.0
onready var current_hp := max_hp
#poison, burn, slowness
var debuffs = {"wilt":0, "fire":0, "rooted":0}
var buffs = {}

#player components
onready var head = $Head
onready var camera = $Head/Camera
#main hitbox(enviromental, projectile collisions)
onready var body = $Body
#holds weapon details, mutations, damage, ammo, etc.
onready var weapon_manager = $Head/Camera/WeaponTransform

#player raycasts
onready var look_cast = $Head/Camera/LookCast
#same as look cast, but used specifically for single shot guns
onready var single_shot = $Head/Camera/SingleShot/Single
#same as single shot, but randomizes angle slightly with each bullet
onready var machine_shot = $Head/Camera/MachineShot/Single
#this is used for the shotgun and checks each ray for enemy collision
onready var cluster_shot = $Head/Camera/ClusterShot.get_children()

#player ui
#visual for crosshair
onready var cross_hair = $Head/Camera/HUD/Crosshair
#UI display for ammo type
onready var ammo_type = $Head/Camera/HUD/AmmoType
#UI display for ammo amount
onready var ammo_amount = $Head/Camera/HUD/AmmoAmount

#dynamic gun variables


#mouse mode - for debugging
var is_center = true



func _ready():
	#locks mouse to center of the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#this tells the weapon manager to send the signal to spawn the gun, because it
	#is ready first
	weapon_manager.init_gun()

#this function handles generalized input, rather stuff that I put in the input map
func _input(event):
	#checks for any mouse movement
	if event is InputEventMouseMotion:
		#rotates the entire body on the y-axis
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		#rotates the head/camera on the x-axis
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		#clamps head rotation to prevent 360s
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89.0), deg2rad(89.0))

func _process(delta):
	#constantly running function for whenever player eats enemy
	consume_enemy()
	#sets ammo text to a dash if infinite
	if is_instance_valid(weapon_manager.active_gun):
		if weapon_manager.active_gun.unlimited_ammo:
			ammo_amount.text = "-"
		else:
			#this is based on the weapon prefab
			#it should be based on the weapon manager's tracked ammo
			ammo_amount.text = str(weapon_manager.active_gun.current_ammo)
	
	#debugging for quick quitting
	if Input.is_action_just_pressed("test_quit"):
		get_tree().quit()
	#debugging for switching mouse mode to center
	if is_center and Input.is_action_just_pressed("switch_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_center = false
	#switching mouse mode to free
	elif !is_center and Input.is_action_just_pressed("switch_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_center = true
func _physics_process(delta):
	#grapple()
	#resetting the direction vector every frame
	direction = Vector3.ZERO
	#gets whatever current y rotation we have from the basis matrix
	var h_rotation = global_transform.basis.get_euler().y
	#gets a float of 1,0,-1 for forward input
	var forward_movement = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	#gets a float of 1,0,-1 for horizontal movement
	var right_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#sets the direction vector with the forward and right inputs, rotated by the current y rotation
	direction = Vector3(right_movement, 0 ,forward_movement).rotated(Vector3.UP,h_rotation).normalized()
	
	#if the player is not jumping/falling
	if is_on_floor():
		#makes center of gravity perpendicular to the floor's facing direction		
		snap = -get_floor_normal()
		#reseting the acceleration gained from falling
		gravity_vector = Vector3.ZERO
		#set acceleration to normal, ie. stop moving faster and get to top speed quicker
		acceleration = default_acceleration
	#if the player is jumping/falling
	elif not is_on_floor():
		#only one direction to stick to
		snap = Vector3.DOWN
		#slower acceleration to hold momentum while jumping
		acceleration = air_acceleration
		#adding the acceleration from gravity, multi * delta for faster falling
		gravity_vector += Vector3.DOWN * gravity * (gravity_multi*delta)
	
	#I can eventually add a variable for double jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		#unsnaps player from ground normal
		snap = Vector3.ZERO
		#add jump acceleration to reach peak faster(look at better jumps in four lines)
		gravity_vector = Vector3.UP * jump_force
	
	#makes for smooth movement by interpolating from whatever the current direction is times speed by delta
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	#creating final movement vector by adding velocity + gravity
	movement = velocity + gravity_vector
	
	#moving the player
	move_and_slide_with_snap(movement,snap,Vector3.UP)
	

#function to swap to new weapon
func spawn_weapon(weapon):
	#should check if the weapon_pos already has a child first
	#everything here may cause problems with more than one gun
	if weapon_manager.get_child_count() == 0:
		var new_weapon = weapon.instance()
		weapon_manager.add_child(new_weapon)
		weapon_manager.active_gun = new_weapon
	
	#assigns gun to primary slot
	if weapon_manager.primary_gun == null:
		weapon_manager.primary_gun = weapon
	
	#assigns gun to secondary slot
	elif weapon_manager.secondary_gun == null:
		weapon_manager.secondary_gun = weapon

func shoot_gun():
	var active_gun = weapon_manager.active_gun
	#match statement to
	if active_gun != null:
		match(active_gun.fire_type):
			"semi":
				if Input.is_action_just_pressed("shoot"):
					active_gun.shoot()
			"semi_burst":
				if Input.is_action_just_pressed("shoot"):
					active_gun.shoot()
			"auto":
				pass
			"auto_burst":
				pass

#consume low health enemy
func consume_enemy():
	#if you're looking at an enemy, it's now your target
	if(look_cast.is_colliding() and look_cast.get_collider().is_in_group("enemy")):
		target_enemy = look_cast.get_collider()
	
	#if you press interact while looking at an enemy you eat it
	if Input.is_action_just_pressed("interact") and target_enemy != null:
		#number here for eat speed, but will replace with stat
		target_enemy.move_to_player(5.0)
		pass
	
func apply_debuffs():
	for i in debuffs.values():
		#replace with function that applies what the debuff does
		print(debuffs[i])
		#reduce by consumption rate
		debuffs[i] -= 1

func apply_buffs():
	for i in buffs.values():
		#replace with function that applies what the debuff does
		print(buffs[i])
		#reduce by consumption rate
		buffs[i] -= 1

#signal from weapon manager to spawn a weapon
func _on_WeaponTransform_spawn_weapon(weapon):
	spawn_weapon(weapon)
