extends KinematicBody

var hp := 50.0
onready var current_hp := hp
onready var body = $Body

onready var material = body.mesh.surface_get_material(0)
var pistol_outline = preload("res://toon_outline_pistol.tres")
var shotgun_outline = preload("res://toon_outline_shotgun.tres")
export(String) var mutation 


func _ready():
	pass

func _process(delta):
	if current_hp <= (hp / 2):
		body.set_mutation(mutation)
	if current_hp <= 0:
		queue_free()
