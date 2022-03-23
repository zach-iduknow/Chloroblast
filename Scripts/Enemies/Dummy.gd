extends KinematicBody

#hp
var hp := 60.0
onready var current_hp := hp
#checks if enemy can be eaten
onready var can_consume = false
#collider
onready var body = $Body
#oil particles
onready var particles = $Body/OilParticles
#player
onready var player = get_tree().get_nodes_in_group("player")[0]

#bool for displaying mutation
var showing_mutation := false
#effect particles
var health_particle = preload("res://Prefabs/General/HealthParticles.tscn")

#checks if being eaten
var being_eaten := false
#speed to be eaten
var eat_speed

#gun to drop
export(String, "none","pistol", "shotgun", "machine") var mutation

#effect given, this will be randomized 
export(String, "none", "health", "ammo", "damage") var effect

func _ready():
	pass

func _process(delta):
	#if the enemy is not already showing their mutation and is at half health, show mutation
	if current_hp <= (hp / 2) and showing_mutation == false:
		can_consume = true
		body.set_mutation(mutation)
		spawn_effect()
		showing_mutation = true
	#die if killed
	if current_hp <= 0:
		queue_free()
	
	if being_eaten == true:
		#zooms to player based on eat speed
		if transform.origin.distance_to(player.transform.origin) > 4:
			transform.origin = lerp(transform.origin, player.transform.origin, eat_speed * delta)
		else:
			#provide the gun and the mutations
			choose_mutation()
			being_eaten = false
			queue_free()
	
func take_damage(dmg):
	current_hp -= dmg
	particles.emitting = true

func spawn_effect():
	if effect == "health":
		var new_particle = health_particle.instance()
		body.add_child(new_particle)

func move_to_player(speed):
	print("arrrg")
	if(current_hp <= hp/2):
		being_eaten = true
		eat_speed = speed

func choose_mutation():
	var mutations = player.weapon_manager
	match mutation:
		"pistol":
			#choses a random mutation from the player's unlocked pistol mutation
			var pistol_mutation = mutations.pistol_mutations[randi() % mutations.pistol_mutations.size()]
			if mutations.current_pistol_mutation == null:
				mutations.current_pistol_mutation = pistol_mutation
		"shotgun":
			pass
		"machine":
			pass
