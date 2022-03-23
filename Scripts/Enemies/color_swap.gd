extends MeshInstance

#preloaded outlines for what fun an enemy drops
var shotgun_outline = preload("res://toon_outline_shotgun.tres")
var pistol_outline = preload("res://toon_outline_pistol.tres")
#gets material on enemy
onready var mat = get_active_material(0)

func _ready():
	pass

#sets material's next pass to whatever it's gun is
func set_mutation(mutation):
	if mutation == "pistol":
		mat.next_pass = pistol_outline
	if mutation == "shotgun":
		mat.next_pass = shotgun_outline
