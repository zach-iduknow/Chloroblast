extends MeshInstance


var shotgun_outline = preload("res://toon_outline_shotgun.tres")
var pistol_outline = preload("res://toon_outline_pistol.tres")
onready var mat = get_active_material(0)

func _ready():
	pass
	
func set_mutation(mutation):
	if mutation == "pistol":
		mat.next_pass = pistol_outline
	if mutation == "shotgun":
		mat.next_pass = shotgun_outline
