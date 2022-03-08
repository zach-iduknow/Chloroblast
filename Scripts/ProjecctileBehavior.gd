extends RigidBody

var damage = 50
var speed = 10

var shoot = false

func _ready():
	set_as_toplevel(true)
	print("here")

func _physics_process(delta):
	if shoot:
		apply_impulse(transform.basis.z, - transform.basis.z)




func _on_Area_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= damage
		queue_free()
	else:
		queue_free()
