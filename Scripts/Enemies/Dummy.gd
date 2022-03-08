extends RigidBody

var hp = 50


func _ready():
	pass

func _process(delta):
	if hp <= 0:
		queue_free()
