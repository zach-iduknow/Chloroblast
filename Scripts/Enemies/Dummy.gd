extends KinematicBody

var hp := 50.0
onready var current_hp := hp
onready var body = $Body
onready var particles = $Body/OilParticles

var showing_mutation := false
var health_particle = preload("res://Prefabs/General/HealthParticles.tscn")

onready var material = body.mesh.surface_get_material(0)

export(String, "none","pistol", "shotgun", "machine") var mutation 
export(String, "none", "health", "ammo", "damage") var effect

func _ready():
	pass

func _process(delta):
	if current_hp <= (hp / 2) and showing_mutation == false:
		body.set_mutation(mutation)
		spawn_effect()
		showing_mutation = true
	if current_hp <= 0:
		queue_free()

func take_damage(dmg):
	current_hp -= dmg
	particles.emitting = true

func spawn_effect():
	if effect == "health":
		var new_particle = health_particle.instance()
		body.add_child(new_particle)
