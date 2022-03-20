extends KinematicBody

var hp := 50.0
onready var current_hp := hp
onready var can_consume = false
onready var body = $Body
onready var particles = $Body/OilParticles
onready var player = get_tree().get_nodes_in_group("player")[0]

var showing_mutation := false
var health_particle = preload("res://Prefabs/General/HealthParticles.tscn")

var being_eaten := false
var eat_speed

export(String, "none","pistol", "shotgun", "machine") var mutation
#this will be randomized 
export(String, "none", "health", "ammo", "damage") var effect

func _ready():
	pass

func _process(delta):
	if current_hp <= (hp / 2) and showing_mutation == false:
		can_consume = true
		body.set_mutation(mutation)
		spawn_effect()
		showing_mutation = true
	if current_hp <= 0:
		queue_free()
	
	if being_eaten == true:
		if transform.origin.distance_to(player.transform.origin) > 4:
			transform.origin = lerp(transform.origin, player.transform.origin, eat_speed * delta)
			print(transform.origin.distance_to(player.transform.origin))
		
		else:
			#provide the gun and the mutations
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
