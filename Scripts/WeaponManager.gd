extends Position3D

#weapon holders
var primary_gun = null
var secondary_gun = null
onready var active_gun = primary_gun
#melee mutation tracker
var melee_mutation


func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("swap_gun"):
		if active_gun == primary_gun and secondary_gun != null:
			active_gun = secondary_gun
		elif active_gun == secondary_gun and primary_gun != null:
			active_gun = primary_gun
		else:
			print("no other weapon to swap too!")
			
