extends Spatial

var damage = 10
#flag for infinite ammo
var unlimited := false
var ammo = 100
var ammo_consumption = 1
#full auto
var time_btw_fire := 0
onready var curr_time_btw_fire := time_btw_fire

onready var weapon_cast = $Barrel/RayCast

func _ready():
	pass

func _process(delta):
	if curr_time_btw_fire > 0:
		curr_time_btw_fire -= 1
	if weapon_cast.is_colliding() and weapon_cast.is_in_group("enemy"):
		print("enemy found")

#this will shoot the ray out
func shoot():
	if curr_time_btw_fire <= 0:
		if !unlimited and ammo >= ammo_consumption:
			ammo -= ammo_consumption
		print("bang")
		if weapon_cast.is_colliding():
			var target = weapon_cast.get_collider()
			if target.is_in_group("enemy"):
				print("hit dummy")
				var enemy = weapon_cast.get_collider()
				enemy.hp -= damage
		#curr_time_btw_fire = time_btw_fire
	
