extends KinematicBody

#How I think I should handle this:
#1) Give the player a target object in the player prefab
#2) When player confirms target, have projectile fire out from top
#	2b) I'll give the projectile a brief moment where it can't hit a wall to ensure it doesn't collide with environment
#3) Detonate on enemy or environment and do a damage tick in a certain area
#	3b) I haven't developed an enemy or a damage system, so lay foundation in place for future enemy

func _ready():
	pass

func _physics_process(delta):
	pass

#Different projectile Behaviors

#arching shot to target location
func mortar():
	pass
