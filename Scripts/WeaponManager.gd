extends Position3D

#Ammo types
export var max_pistol := 100
onready var curr_pistol := max_pistol

export var max_shotgun := 25
onready var curr_shotgun := max_shotgun

export var max_machine := 250
onready var curr_machine := max_machine

#seedshot(starter pistol) items
var seedshot = preload("res://Prefabs/Weapons/seedshot.tscn")
#double shouldn't be unlocked yet
var seedshot_mutations = ["double"]
var current_seedshot_mutation

#sunflakker(shotgun) items
var sunflakker = preload("res://Prefabs/Weapons/sunflakker.tscn")
var sunflakker_mutaions = []
var current_sunflakker_mutation

#pepper grinder items
var pepper_grinder
var pepper_grinder_mtations = []
var current_pepper_grinder_mutation

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

#signal to player to spawn gun, for now it's the pistol
func init_gun():
	print("start up")
	emit_signal("spawn_weapon",sunflakker)
