extends Position3D

#weapons
var pistol = preload("res://Prefabs/Weapons/pistol.tscn")
#double shouldn't be unlocked yet
var pistol_mutations = ["double"]
var current_pistol_mutation

var shotgun
var shotgun_mutaions = []
var current_shotgun_mutation

var machine_gun
var machine_mtations = []
var current_machine_mutation

#sends a weapon to the player script to switch weapons
signal spawn_weapon(weapon)

#weapon holders
var primary_gun = null
var secondary_gun = null
onready var active_gun = primary_gun
#melee mutation tracker
var melee_mutation


func _ready():
	pass

func _process(delta):
	#this is probably too complicated
	if Input.is_action_just_pressed("swap_gun"):
		if active_gun == primary_gun and secondary_gun != null:
			active_gun = secondary_gun
		elif active_gun == secondary_gun and primary_gun != null:
			active_gun = primary_gun
		else:
			print("no other weapon to swap too!")

func init_gun():
	emit_signal("spawn_weapon",pistol)
