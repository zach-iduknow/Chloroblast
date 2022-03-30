extends Spatial

#the name will determine what mutations to use
export(String) var gun_name
export(String, "--","pistol", "shotgun", "machine gun") var gun_type
#fire pattern
export(String, "--","semi", "auto", "semi_burst", "auto_burst") var fire_type

#increase value to slow fire rate, decrease to increase
export var time_btw_fire := 0.0
onready var current_time_btw_fire = time_btw_fire
export var damage = 10
#for machine gun
#lower to tighten spread
export var spread_amount := 10.0
var rng = RandomNumberGenerator.new()


#this should be a max(i.e. readonly)

#this should also be a reference
export var ammo_consumption = 1
#full auto

onready var curr_time_btw_fire := time_btw_fire

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var weapon_manager = player.weapon_manager
var weapon_cast
var active_mutation

var current_ammo
#flag for infinite ammo
export var unlimited_ammo := true

func _ready():
	rng.randomize()
	choose_cast()
	#tells gun what ammo reserve to take from
	#this resets each time a new weapon spawns
	match(gun_type):
		"pistol":
			current_ammo = weapon_manager.curr_pistol
		"shotgun":
			current_ammo = weapon_manager.curr_shotgun
		"machine":
			current_ammo = weapon_manager.curr_machine

func _process(delta):
	#sets the active mutation to whatever the player has
	set_mutation()
	
	#used to control fire rate/type
	if curr_time_btw_fire > 0:
		curr_time_btw_fire -= 1

func _physics_process(delta):
	match(fire_type):
		"semi":
			if Input.is_action_just_pressed("shoot"): shoot()
		"auto":
			if Input.is_action_pressed("shoot"): shoot()
		"semi_burst":
			if Input.is_action_just_pressed("shoot"): shoot()
		"auto_burst":
			if Input.is_action_pressed("shoot"): shoot()

#choose raycast pattern from player
func choose_cast():
	print("choose cast")
	match(gun_type):
		"pistol":
			weapon_cast = player.single_shot
		"shotgun":
			weapon_cast = player.cluster_shot
		"machine":
			weapon_cast = player.machine_shot

func set_mutation():
	match(gun_name):
		"Seedshot":
			active_mutation = player.weapon_manager.current_seedshot_mutation
		"Sunflakker":
			active_mutation = player.weapon_manager.current_sunflakker_mutation
		"Pepper Grinder":
			active_mutation = player.weapon_manager.current_pepper_grinder_mutation
#general function to call correct fire function
func shoot():
	#nested if statement to check if the player can shoot
	#and has the ammo to do so
	if curr_time_btw_fire <= 0:
		if !unlimited_ammo:
			if current_ammo >= ammo_consumption:
				current_ammo -= ammo_consumption
				bullet_pattern()
				curr_time_btw_fire = time_btw_fire
		else:
			bullet_pattern()
			curr_time_btw_fire = time_btw_fire


#choose firing type
func bullet_pattern():
	match(gun_type):
		"pistol":
			single_shot()
		"shotgun":
			cluster_shot()
		"machine":
			machine_shot()

#this will shoot the ray out, used for guns like the pistol and railgun
func single_shot():
	if weapon_cast.is_colliding():
		var target = weapon_cast.get_collider()
		if target.is_in_group("enemy"):
			target.take_damage(damage)
#mutation system will have to be redone if I do a bunch of different guns

#used for shotgun patterns
func cluster_shot():
	var x = 0
	for i in weapon_cast:
		if i.is_colliding():
			var target = i.get_collider()
			if target.is_in_group("enemy"):
				print("Ray: " + str(x) +" hit")
				x += 1
				target.take_damage(damage)
	print("--------")
	x = 0 

#used for machine gun, ray randomized angle slightly with each bullet
func machine_shot():
	#finds a random value for each axis between -10 and 10
	var rand_x = rng.randf(-spread_amount,spread_amount)
	var rand_y = rng.randf(-spread_amount,spread_amount)
	var rand_z = rng.randf(-spread_amount,spread_amount)
	#rotates the ray by each random amount on each axis(need to test this)
	weapon_cast.rotate_object_local(Vector3(1,0,0),rand_x)
	weapon_cast.rotate_object_local(Vector3(0,1,0),rand_x)
	weapon_cast.rotate_object_local(Vector3(0,0,1),rand_x)
	if weapon_cast.is_colliding():
		var target = weapon_cast.get_collider()
		if target.is_in_group("enemy"):
			target.take_damage(damage)
